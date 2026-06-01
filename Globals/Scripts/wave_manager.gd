extends Node

enum Phase {
	IDLE,
	IN_WAVE,
	SUMMONING_ENEMIES,
	INTERMISSION
}

var wave_data: Dictionary = {}

var intermission_duration: float = 0.0
var intermissionTimer: SceneTreeTimer = null

var SECOND_TIER_UNLOCK_WAVE
var THIRD_TIER_UNLOCK_WAVE

var spawnQueue: Array = []

var activeEnemies : Dictionary = {}

var systems = ["Similar","Ordered","Anti-Ordered","Mixed"]
var tierOneEnemyTypes = {"Similar" : Enemy.EnemyID.BASIC_SQUARE}
var tierTwoEnemyTypes = {"Similar" : Enemy.EnemyID.SPEEDY_TRIANGLE}
var tierThreeEnemyTypes = {"Similar" : Enemy.EnemyID.SHOOTY_DIAMOND}
var bossEnemies = {"Similar" : Enemy.EnemyID.HEXAGON_MOTHERSHIP}

var currentDifficulty = 1

var currentWave = 0
var systemNumber = 0
var currentSystem = "Similar"
var currentPhase : Phase = Phase.IDLE

func _ready() -> void:
	loadData()
	#beginNextWave()

func beginNextWave():

	currentWave += 1
	
	if currentWave > get_waves_per_system():
		currentWave = 0
		beginNextSystem()
		return
	
	currentPhase = Phase.SUMMONING_ENEMIES
	
	spawnQueue = buildSpawnQueue()
	
	spawnNext()
	
	manageWaveInfoUI(0)

func beginNextSystem():
	systemNumber += 1
	
	# Generate random system but for now we set it manually
	currentSystem = "Similar"
	
	intermission_duration = get_system_transition_time(currentDifficulty)
	intermissionTimer = get_tree().create_timer(intermission_duration)
	manageWaveInfoUI(intermission_duration)
	intermissionTimer.timeout.connect(beginNextWave)
	

func onWaveComplete() -> void: 
	currentPhase = Phase.INTERMISSION
	
	var duration = get_intermission_duration(currentDifficulty)
	intermissionTimer = get_tree().create_timer(duration)
	intermissionTimer.timeout.connect(beginNextWave)
	manageWaveInfoUI(duration)

func manageWaveInfoUI(duration):
	var bottomUI = get_tree().current_scene
	if bottomUI != null:
		if bottomUI.has_node("WaveData"):
			bottomUI = bottomUI.find_child("WaveData")
		bottomUI.refreshWaveInfo(duration)

func buildSpawnQueue() -> Array:
	var queue: Array = []

	# Boss waves are solo — one mothership, nothing else
	if is_boss_wave():
		queue.append(Enemy.EnemyID.HEXAGON_MOTHERSHIP)
		SoundManager.playBossWaveSound()

	var waveWithinSystem = ((currentWave - 1) % get_waves_per_system()) + 1

	var baseline = get_starting_enemies() + waveWithinSystem * get_wave_enemy_growth()
	var difficultyMult = get_enemy_count_multiplier(currentDifficulty)
	var systemMult = get_scaled_system_enemy_multiplier()
	var total = clampi(floori(baseline * difficultyMult * systemMult), 1, get_max_enemies_per_wave())

	var activeTiers = getActiveTiers(waveWithinSystem)

	var counts = { "first": 0, "second": 0, "third": 0 }

	if not activeTiers["second"] and not activeTiers["third"]:
		# only first tier then give it everything
		counts["first"] = total
	elif not activeTiers["third"]:
		# first and second only then rescale their weights to fill 100%
		var combinedWeight = get_first_tier_weight() + get_second_tier_weight()
		counts["first"]  = floori(total * (get_first_tier_weight() / combinedWeight))
		counts["second"] = total - counts["first"]
	else:
		# distribute normally
		counts["first"]  = floori(total * get_first_tier_weight())
		counts["second"] = floori(total * get_second_tier_weight())
		counts["third"]  = floori(total * get_third_tier_weight())
		var assigned = counts["first"] + counts["second"] + counts["third"]
		counts["first"] += total - assigned

	for i in counts["first"]:
		queue.append(tierOneEnemyTypes.get(currentSystem))
	for i in counts["second"]:
		queue.append(tierTwoEnemyTypes.get(currentSystem))
	for i in counts["third"]:
		queue.append(tierThreeEnemyTypes.get(currentSystem))

	queue.shuffle()
	
	for item in queue:
		if activeEnemies.has(item):
			activeEnemies[item] = activeEnemies.get(item) + 1
		else:
			activeEnemies[item] = 1
	
	return queue

func getActiveTiers(waveWithinSystem: int) -> Dictionary:
	var tiers = {
		"first":  true,
		"second": waveWithinSystem >= SECOND_TIER_UNLOCK_WAVE,
		"third":  waveWithinSystem >= THIRD_TIER_UNLOCK_WAVE,
	}
	return tiers

func removeActiveEnemy(enemy : Enemy):
	var id = enemy.enemyID
	
	if activeEnemies.has(id):
		if activeEnemies.get(id) <= 1:
			activeEnemies.erase(id)
		else:
			activeEnemies[id] = activeEnemies.get(id) - 1

func checkForEnemiesAlive():
	if activeEnemies.size() <= 0:
		onWaveComplete()
		

func registerActiveEnemy(enemy: Enemy) -> void:
	var id = enemy.enemyID
	if activeEnemies.has(id):
		activeEnemies[id] += 1
	else:
		activeEnemies[id] = 1

func spawnNext() -> void:
	if spawnQueue.is_empty():
		currentPhase = Phase.IN_WAVE
		return

	var enemyID: Enemy.EnemyID = spawnQueue.pop_front()
	EnemySpawnManager.summonEnemy(enemyID)

	var interval := get_spawn_interval(currentDifficulty)
	get_tree().create_timer(interval).timeout.connect(spawnNext)

func is_boss_wave() -> bool:
	return currentWave % get_waves_per_system() == 0

func get_current_system() -> int:
	return ceili(float(currentWave) / float(get_waves_per_system()))

func get_scaled_system_enemy_multiplier() -> float:
	return pow(get_system_enemy_multiplier(), systemNumber - 1)

func get_starting_enemies() -> int:
	return int(wave_data["baseline"]["startingEnemies"])

func get_wave_enemy_growth() -> float:
	return float(wave_data["baseline"]["waveEnemyGrowth"])

func get_max_enemies_per_wave() -> int:
	return int(wave_data["baseline"]["maxEnemiesPerWave"])

func get_base_spawn_interval() -> float:
	return float(wave_data["baseline"]["baseSpawnIntervalSec"])

func get_wave_count() -> int:
	return int(wave_data["baseline"]["wave_count"])

func get_boss_min_wave() -> int:
	return int(wave_data["baseline"]["bossMinWave"])

func get_group_weights() -> Dictionary:
	return wave_data["baseline"]["groupWeights"] as Dictionary

func get_first_tier_weight() -> float:
	return float(wave_data["baseline"]["groupWeights"]["firstTier"])

func get_second_tier_weight() -> float:
	return float(wave_data["baseline"]["groupWeights"]["secondTier"])

func get_third_tier_weight() -> float:
	return float(wave_data["baseline"]["groupWeights"]["thirdTier"])

func get_boss_weight() -> float:
	return float(wave_data["baseline"]["groupWeights"]["boss"])

func _get_difficulty(level: int) -> Dictionary:
	for entry in wave_data["difficulties"]:
		if entry["level"] == level:
			return entry
	push_error("WaveInfo: difficulty level %d not found" % level)
	return {}

func get_system_count() -> int:
	return int(wave_data["baseline"]["systemScaling"]["systemCount"])

func get_waves_per_system() -> int:
	return int(wave_data["baseline"]["systemScaling"]["wavesPerSystem"])

func get_system_enemy_multiplier() -> float:
	return float(wave_data["baseline"]["systemScaling"]["enemyMultiplierPerSystem"])

func get_tier_two_enemy_wave_tresh() -> float:
	return float(wave_data["baseline"]["systemScaling"]["tierTwoWaveTresh"])

func get_tier_three_enemy_wave_tresh() -> float:
	return float(wave_data["baseline"]["systemScaling"]["tierThreeWaveTresh"])

func get_label(level: int) -> String:
	return str(_get_difficulty(level).get("label", ""))

func get_enemy_count_multiplier(level: int) -> float:
	return float(_get_difficulty(level).get("enemy_count_multiplier", 1.0))

func get_system_transition_time(level: int) -> float:
	return float(_get_difficulty(level).get("systemTransitionDurationSec", 1.0))

func get_spawn_interval(level: int) -> float:
	return float(_get_difficulty(level).get("spawn_interval_sec", 1.0))

func get_intermission_duration(level: int) -> float:
	return float(_get_difficulty(level).get("intermission_duration_sec", 10.0))

func get_health_scale_per_wave() -> float:
	return float(wave_data["baseline"]["waveScaling"]["healthScalePerWave"])

func get_damage_scale_per_wave() -> float:
	return float(wave_data["baseline"]["waveScaling"]["damageScalePerWave"])

func loadData():
	var file := FileAccess.open("res://Config/Wave Info.json", FileAccess.READ)
	if file == null:
		push_error("WaveInfo: could not open 'Wave Info.json' — error: %d" % FileAccess.get_open_error())
		return

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err != OK:
		push_error("WaveInfo: JSON parse error — %s" % json.get_error_message())
		return

	wave_data = json.data as Dictionary
	intermission_duration = float(wave_data.get("intermission_duration_sec", 0.0))
	SECOND_TIER_UNLOCK_WAVE = get_tier_two_enemy_wave_tresh()
	THIRD_TIER_UNLOCK_WAVE = get_tier_three_enemy_wave_tresh()

func reset() -> void:
	# Clear timers
	if intermissionTimer != null:
		intermissionTimer = null

	# Cancel any pending spawns by clearing the queue
	spawnQueue.clear()
	activeEnemies.clear()

	# Reset wave state
	currentWave = 0
	systemNumber = 0
	currentSystem = systems[0]
	currentPhase = Phase.IDLE
