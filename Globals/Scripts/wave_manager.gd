extends Node

enum Phase {
	IDLE,
	IN_WAVE,
	SUMMONING_ENEMIES,
	INTERMISSION
}

# --- Core Data ---
var waveData: Dictionary = {}
var activeEnemies: Dictionary = {}
var spawnQueue: Array = []

var intermissionDuration: float = 0.0
var intermissionTimer: SceneTreeTimer = null

var secondTierUnlockWave: int
var thirdTierUnlockWave: int

# --- Enemy Configurations ---
var systems: Array[String] = ["Similar", "Ordered", "Anti-Ordered", "Mixed"]
var tierOneEnemyTypes: Dictionary = {"Similar": [Enemy.EnemyID.BASIC_SQUARE]}
var tierTwoEnemyTypes: Dictionary = {"Similar": [Enemy.EnemyID.SPEEDY_TRIANGLE, Enemy.EnemyID.TANKY_RECTANGLE]}
var tierThreeEnemyTypes: Dictionary = {"Similar": [Enemy.EnemyID.SHOOTY_DIAMOND]}
var bossEnemies: Dictionary = {"Similar": Enemy.EnemyID.HEXAGON_MOTHERSHIP}

# --- State Variables ---
var currentDifficulty: int = 1
var currentWave: int = 0
var systemNumber: int = 1
var currentSystem: String = "Similar"
var currentPhase: Phase = Phase.IDLE
var generation: int = 0 # Increments on reset to invalidate stale closures

# --- Message Variables ---
var eventNotified : bool = true

func _ready() -> void:
	loadData()


func beginNextWave() -> void:
	SoundManager.startTimer(randf_range(5.0, 20.0))

	currentWave += 1

	if currentWave > getWavesPerSystem():
		currentWave = 0
		beginNextSystem()
		StatManager.systemsCompleted += 1
		if currentDifficulty >= 3:
			AchievementManager.unlock_achievement("ACH_SYSTEM_COMPLETE_1")
		if currentDifficulty >= 4 and systemNumber >= 3:
			AchievementManager.unlock_achievement("ACH_SYSTEM_COMPLETE_2")
		return

	currentPhase = Phase.SUMMONING_ENEMIES
	spawnQueue = buildSpawnQueue()
	scheduleEventRoll(spawnQueue.size())
	spawnNext()
	manageWaveInfoUI(0.0)

func beginNextSystem() -> void:
	systemNumber += 1
	
	currentSystem = "Similar"
	
	if systemNumber >= 2:
		get_tree().create_timer(randi_range(0,20), false).timeout.connect(_makeCallback(func():
			PopupManager.eventNotify()
		))

	intermissionDuration = getSystemTransitionTime(currentDifficulty)
	
	# Passing false to respect the pause state
	intermissionTimer = get_tree().create_timer(intermissionDuration, false)
	manageWaveInfoUI(intermissionDuration)
	intermissionTimer.timeout.connect(_makeCallback(beginNextWave))

func onWaveComplete() -> void:
	var duration = getIntermissionDuration(currentDifficulty)
	
	# Passing false to respect the pause state
	intermissionTimer = get_tree().create_timer(duration, false)
	intermissionTimer.timeout.connect(_makeCallback(beginNextWave))
	
	if currentDifficulty >= 2:
		if currentWave == 5:
			AchievementManager.unlock_achievement("ACH_WAVE_5_DIFF_2")
	
	manageWaveInfoUI(duration)
	StatManager.wavesCompleted += 1
	currentPhase = Phase.INTERMISSION




# --- Spawning Logic ---

func spawnNext() -> void:
	if spawnQueue.is_empty():
		currentPhase = Phase.IN_WAVE
		return

	var enemyID: Enemy.EnemyID = spawnQueue.pop_front()
	
	
	EnemySpawnManager.summonEnemy(enemyID)

	var waveWithinSystem = getWaveWithinSystem()
	var interval = getSpawnInterval(currentDifficulty, waveWithinSystem)
	
	# Passing false to respect the pause state
	get_tree().create_timer(interval, false).timeout.connect(_makeCallback(spawnNext))

func buildSpawnQueue() -> Array:
	var queue: Array = []

	if isBossWave():
		queue.append(Enemy.EnemyID.HEXAGON_MOTHERSHIP)
		SoundManager.playBossWaveSound()

	var waveWithinSystem = getWaveWithinSystem()
	var totalWaveIndex = getTotalWaveIndex()


	var baseline = getStartingEnemies() + (totalWaveIndex * getWaveEnemyGrowth())
	var difficultyMult = getEnemyCountMultiplier(currentDifficulty)

	var waveProgressMult = getWaveCountScale(currentDifficulty, waveWithinSystem)
	var systemMult = getScaledSystemEnemyMultiplier()

	var total = clampi(
		floori(baseline * difficultyMult * waveProgressMult * systemMult),
		1,
		getMaxEnemiesPerWave()
	)

	var activeTiers = getActiveTiers(waveWithinSystem)
	var counts = { "first": 0, "second": 0, "third": 0 }

	if not activeTiers["second"] and not activeTiers["third"]:
		counts["first"] = total
	elif not activeTiers["third"]:
		var combinedWeight = getFirstTierWeight() + getSecondTierWeight()
		counts["first"]  = floori(total * (getFirstTierWeight() / combinedWeight))
		counts["second"] = total - counts["first"]
	else:
		counts["first"]  = floori(total * getFirstTierWeight())
		counts["second"] = floori(total * getSecondTierWeight())
		counts["third"]  = floori(total * getThirdTierWeight())
		var assigned = counts["first"] + counts["second"] + counts["third"]
		counts["first"] += total - assigned

	for i in counts["first"]:
		queue.append(getEnemyFromTier(tierOneEnemyTypes))
	for i in counts["second"]:
		queue.append(getEnemyFromTier(tierTwoEnemyTypes))
	for i in counts["third"]:
		queue.append(getEnemyFromTier(tierThreeEnemyTypes))

	queue.shuffle()

	for item in queue:
		if activeEnemies.has(item):
			activeEnemies[item] += 1
		else:
			activeEnemies[item] = 1

	return queue


# --- Enemy Management ---

func getEnemyFromTier(tierDict: Dictionary) -> Enemy.EnemyID:
	var pool: Array = tierDict.get(currentSystem, [])
	if pool.is_empty():
		return Enemy.EnemyID.BASIC_SQUARE
	return pool[randi() % pool.size()]

func getActiveTiers(waveWithinSystem: int) -> Dictionary:
	var pastFirstSystem: bool = systemNumber > 1
	
	return {
		"first":  true,
		"second": pastFirstSystem or waveWithinSystem >= secondTierUnlockWave,
		"third":  pastFirstSystem or waveWithinSystem >= thirdTierUnlockWave,
	}

func removeActiveEnemy(enemy: Enemy) -> void:
	var id = enemy.enemyID

	if activeEnemies.has(id):
		if activeEnemies[id] <= 1:
			activeEnemies.erase(id)
		else:
			activeEnemies[id] -= 1
			
		# ONLY check for wave completion if we actually successfully removed a registered enemy
		checkForEnemiesAlive()
	else:
		push_warning("WaveManager: Tried to remove an enemy with an unregistered ID!")
		# Notice we removed the checkForEnemiesAlive() from down here!

func checkForEnemiesAlive() -> void:
	if currentPhase == Phase.INTERMISSION:
		return
		
	if activeEnemies.size() <= 0:
		onWaveComplete()

func registerActiveEnemy(enemy: Enemy) -> void:
	var id = enemy.enemyID
	if activeEnemies.has(id):
		activeEnemies[id] += 1
	else:
		activeEnemies[id] = 1


# --- Event System ---

func scheduleEventRoll(queueSize: int) -> void:
	# systemNumber is 0 for the whole first system and only increments in beginNextSystem(),
	# so this compares directly against eventSystemThresh. Flip to "- 1" if you intend
	# eventSystemThresh to line up with the displayed/first system instead.
	if systemNumber < getEventSystemThresh():
		return

	var waveWithinSystem = getWaveWithinSystem()
	var estimatedDuration = estimateWaveDuration(waveWithinSystem, queueSize)
	var eventDelay = randf_range(0.0, estimatedDuration)
	var waveAtSchedule = currentWave

	# Passing false to respect the pause state
	get_tree().create_timer(eventDelay, false).timeout.connect(_makeCallback(func():
		if currentWave != waveAtSchedule:
			return
		if currentPhase != Phase.IN_WAVE and currentPhase != Phase.SUMMONING_ENEMIES:
			return
		rollForEvent()
	))

func estimateWaveDuration(waveWithinSystem: int, queueSize: int) -> float:
	var interval = getSpawnInterval(currentDifficulty, waveWithinSystem)
	var enemyCount = maxi(queueSize, 1)
	return maxf(float(enemyCount) * interval, 1.0)

func rollForEvent() -> void:
	var roll = randf_range(0.0, 100.0)
	if roll < getEventChance(currentDifficulty):
		startEvent()

func startEvent():
	var events = ["Boss","Rift","Formation"]
	match events.pick_random():
		"Boss":
			EnemySpawnManager.bossEvent()
			PopupManager.eventPopup("boss")
		"Rift":
			EnemySpawnManager.riftEvent()
			PopupManager.eventPopup("rift")
		"Formation":
			EnemySpawnManager.formationEvent()
			PopupManager.eventPopup("formation")


# --- Data Getters ---

func isBossWave() -> bool:
	return currentWave % getWavesPerSystem() == 0

func getCurrentSystem() -> int:
	return ceili(float(currentWave) / float(getWavesPerSystem()))

func getWaveWithinSystem() -> int:
	return ((currentWave - 1) % getWavesPerSystem()) + 1

func getTotalWaveIndex() -> int:
	return ((systemNumber - 1) * getWavesPerSystem()) + getWaveWithinSystem()

func getDifficulty(level: int) -> Dictionary:
	for entry in waveData.get("difficulties", []):
		if entry.get("level") == level:
			return entry
	push_error("WaveInfo: difficulty level %d not found" % level)
	return {}

# --- [1] Baseline Config Getters ---
func getStartingEnemies() -> int: return int(waveData["baseline"]["startingEnemies"])
func getWaveEnemyGrowth() -> float: return float(waveData["baseline"]["waveEnemyGrowth"])
func getMaxEnemiesPerWave() -> int: return int(waveData["baseline"]["maxEnemiesPerWave"])
func getBaseSpawnInterval() -> float: return float(waveData["baseline"]["baseSpawnIntervalSec"])
func getBossMinWave() -> int: return int(waveData["baseline"]["bossMinWave"])

# --- [2] Thresholds, Events & Elites (NEW) ---
func getEventSystemThresh() -> int: return int(waveData["baseline"]["eventSystemThresh"])
func getEliteSystemThresh() -> int: return int(waveData["baseline"]["eliteSystemThresh"])
func getRiftEventEnemiesSpawned() -> int: return int(waveData["baseline"]["riftEvent"]["enemiesSpawned"])
func getRiftEventEnemySpawnInterval() -> float: return float(waveData["baseline"]["riftEvent"]["enemySpawnInterval"])

# --- [3] Weights ---
func getGroupWeights() -> Dictionary: return waveData["baseline"]["groupWeights"] as Dictionary
func getFirstTierWeight() -> float: return float(waveData["baseline"]["groupWeights"]["firstTier"])
func getSecondTierWeight() -> float: return float(waveData["baseline"]["groupWeights"]["secondTier"])
func getThirdTierWeight() -> float: return float(waveData["baseline"]["groupWeights"]["thirdTier"])
func getBossWeight() -> float: return float(waveData["baseline"]["groupWeights"]["boss"])

# --- [4] System Scaling Config ---
func getSystemCount() -> int: return int(waveData["baseline"]["systemScaling"]["systemCount"])
func getWavesPerSystem() -> int: return int(waveData["baseline"]["systemScaling"]["wavesPerSystem"])
func getTierTwoEnemyWaveThresh() -> float: return float(waveData["baseline"]["systemScaling"]["tierTwoWaveThresh"])
func getTierThreeEnemyWaveThresh() -> float: return float(waveData["baseline"]["systemScaling"]["tierThreeWaveThresh"])

# Base Multipliers (NEW)
func getSystemEnemyMultiplier() -> float: return float(waveData["baseline"]["systemScaling"]["enemyMultiplierPerSystem"])
func getSystemHealthMultiplier() -> float: return float(waveData["baseline"]["systemScaling"]["healthMultiplierPerSystem"])
func getSystemSpeedMultiplier() -> float: return float(waveData["baseline"]["systemScaling"]["speedMultiplierPerSystem"])
func getSystemDamageMultiplier() -> float: return float(waveData["baseline"]["systemScaling"]["damageMultiplierPerSystem"])
func getSystemSpawnIntervalReduction() -> float: return float(waveData["baseline"]["systemScaling"]["spawnIntervalReductionPerSystem"])


func getScaledSystemEnemyMultiplier() -> float: return pow(getSystemEnemyMultiplier(), maxi(0, systemNumber - 1))
func getScaledSystemHealthMultiplier() -> float: return pow(getSystemHealthMultiplier(), maxi(0, systemNumber - 1))
func getScaledSystemSpeedMultiplier() -> float: return pow(getSystemSpeedMultiplier(), maxi(0, systemNumber - 1))
func getScaledSystemDamageMultiplier() -> float: return pow(getSystemDamageMultiplier(), maxi(0, systemNumber - 1))
func getScaledSystemSpawnIntervalReduction() -> float: return pow(getSystemSpawnIntervalReduction(), maxi(0, systemNumber - 1))

# --- [5] Wave Scaling Config ---
func getHealthScalePerWave() -> float: return float(waveData["baseline"]["waveScaling"]["healthScalePerWave"])
func getDamageScalePerWave() -> float: return float(waveData["baseline"]["waveScaling"]["damageScalePerWave"])

# --- [6] Difficulty Modifiers ---
func getLabel(level: int) -> String: return str(getDifficulty(level).get("label", ""))
func getEnemyCountMultiplier(level: int) -> float: return float(getDifficulty(level).get("enemy_count_multiplier", 1.0))
func getSystemTransitionTime(level: int) -> float: return float(getDifficulty(level).get("systemTransitionDurationSec", 1.0))
func getSpawnIntervalDecay(level: int) -> float: return float(getDifficulty(level).get("spawnIntervalDecayPerWave", 1.0))
func getIntermissionDuration(level: int) -> float: return float(getDifficulty(level).get("intermission_duration_sec", 10.0))
func getEventChance(level: int) -> float: return float(getDifficulty(level).get("eventChance", 0.0)) # NEW

func getSpawnInterval(level: int, waveWithinSystem: int = 1) -> float:
	var base = float(getDifficulty(level).get("spawn_interval_sec", 1.0))
	var decay = getSpawnIntervalDecay(level)
	var floorInterval = getBaseSpawnInterval()
	# --- REVAMP: system-level speed-up ---
	# spawnIntervalReductionPerSystem was already in the config and had a scaled
	# getter (getScaledSystemSpawnIntervalReduction), but nothing multiplied it in —
	# so spawn interval reset to the difficulty's base value at the start of every
	# system instead of continuing to ramp up. Wired in below.
	var systemReduction = getScaledSystemSpawnIntervalReduction()
	var interval = base * pow(decay, waveWithinSystem - 1) * systemReduction
	return maxf(interval, floorInterval)

func getWaveCountScale(level: int, waveWithinSystem: int) -> float:
	var scale := float(getDifficulty(level).get("waveCountScalePerWave", 1.0))
	return pow(scale, waveWithinSystem - 1)

func getEliteChance(level: int) -> float: return float(getDifficulty(level).get("eliteChance", 0.0))
func getEliteChanceIncreasePerWave(level: int) -> float: return float(getDifficulty(level).get("eliteChanceIncreasePerWave", 0.0))

func getScaledEliteChance(level: int, totalWavesCompleted: int) -> float:
	var base_chance = getEliteChance(level)
	var increase_per_wave = getEliteChanceIncreasePerWave(level)
	return base_chance + (increase_per_wave * totalWavesCompleted)

# --- Utilities & Data Loading ---

func loadData() -> void:
	var file := FileAccess.open("res://Config/Wave Info.json", FileAccess.READ)
	if not file:
		push_error("WaveInfo: could not open 'Wave Info.json' — error: %d" % FileAccess.get_open_error())
		return

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err != OK:
		push_error("WaveInfo: JSON parse error — %s" % json.get_error_message())
		return

	waveData = json.data as Dictionary
	intermissionDuration = float(waveData.get("intermission_duration_sec", 0.0))
	secondTierUnlockWave = int(getTierTwoEnemyWaveThresh())
	thirdTierUnlockWave = int(getTierThreeEnemyWaveThresh())

func manageWaveInfoUI(duration: float) -> void:
	var bottomUI = get_tree().current_scene
	if bottomUI != null:
		if bottomUI.has_node("WaveData"):
			bottomUI = bottomUI.find_child("WaveData")
		if bottomUI.has_method("refreshWaveInfo"):
			bottomUI.refreshWaveInfo(duration)

func reset() -> void:
	generation += 1  # Invalidates all old timer callbacks
	
	intermissionTimer = null
	spawnQueue.clear()
	activeEnemies.clear()

	currentWave = 0
	systemNumber = 0
	currentDifficulty = 1
	currentSystem = systems[0]
	currentPhase = Phase.IDLE

func _makeCallback(fn: Callable) -> Callable:
	var gen = generation
	return func():
		if generation == gen:
			fn.call()
