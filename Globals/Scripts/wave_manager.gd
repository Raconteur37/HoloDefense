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
var systemNumber: int = 0
var currentSystem: String = "Similar"
var currentPhase: Phase = Phase.IDLE
var generation: int = 0 # Increments on reset to invalidate stale closures


func _ready() -> void:
	loadData()


# --- Wave & System Flow ---

func beginNextWave() -> void:
	SoundManager.startTimer(randf_range(5.0, 20.0))

	currentWave += 1

	if currentWave > getWavesPerSystem():
		currentWave = 0
		beginNextSystem()
		StatManager.systemsCompleted += 1
		return

	currentPhase = Phase.SUMMONING_ENEMIES
	spawnQueue = buildSpawnQueue()
	spawnNext()
	manageWaveInfoUI(0.0)

func beginNextSystem() -> void:
	systemNumber += 1
	currentSystem = "Similar"

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

	var waveWithinSystem = ((currentWave - 1) % getWavesPerSystem()) + 1
	var interval = getSpawnInterval(currentDifficulty, waveWithinSystem)
	
	# Passing false to respect the pause state
	get_tree().create_timer(interval, false).timeout.connect(_makeCallback(spawnNext))

func buildSpawnQueue() -> Array:
	var queue: Array = []

	if isBossWave():
		queue.append(Enemy.EnemyID.HEXAGON_MOTHERSHIP)
		SoundManager.playBossWaveSound()

	var waveWithinSystem = ((currentWave - 1) % getWavesPerSystem()) + 1
	var baseline = getStartingEnemies() + (waveWithinSystem * getWaveEnemyGrowth())
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
	return {
		"first":  true,
		"second": waveWithinSystem >= secondTierUnlockWave,
		"third":  waveWithinSystem >= thirdTierUnlockWave,
	}

func removeActiveEnemy(enemy: Enemy) -> void:
	var id = enemy.enemyID

	if activeEnemies.has(id):
		if activeEnemies[id] <= 1:
			activeEnemies.erase(id)
		else:
			activeEnemies[id] -= 1
	else:
		push_warning("WaveManager: Tried to remove an enemy with an unregistered ID!")
	
	checkForEnemiesAlive()

func checkForEnemiesAlive() -> void:
	if activeEnemies.size() <= 0:
		onWaveComplete()

func registerActiveEnemy(enemy: Enemy) -> void:
	var id = enemy.enemyID
	if activeEnemies.has(id):
		activeEnemies[id] += 1
	else:
		activeEnemies[id] = 1


# --- Data Getters ---

func isBossWave() -> bool:
	return currentWave % getWavesPerSystem() == 0

func getCurrentSystem() -> int:
	return ceili(float(currentWave) / float(getWavesPerSystem()))

func getDifficulty(level: int) -> Dictionary:
	for entry in waveData.get("difficulties", []):
		if entry.get("level") == level:
			return entry
	push_error("WaveInfo: difficulty level %d not found" % level)
	return {}


# Baseline Config Getters
func getStartingEnemies() -> int: return int(waveData["baseline"]["startingEnemies"])
func getWaveEnemyGrowth() -> float: return float(waveData["baseline"]["waveEnemyGrowth"])
func getMaxEnemiesPerWave() -> int: return int(waveData["baseline"]["maxEnemiesPerWave"])
func getBaseSpawnInterval() -> float: return float(waveData["baseline"]["baseSpawnIntervalSec"])
func getWaveCount() -> int: return int(waveData["baseline"]["wave_count"])
func getBossMinWave() -> int: return int(waveData["baseline"]["bossMinWave"])

# Weights
func getGroupWeights() -> Dictionary: return waveData["baseline"]["groupWeights"] as Dictionary
func getFirstTierWeight() -> float: return float(waveData["baseline"]["groupWeights"]["firstTier"])
func getSecondTierWeight() -> float: return float(waveData["baseline"]["groupWeights"]["secondTier"])
func getThirdTierWeight() -> float: return float(waveData["baseline"]["groupWeights"]["thirdTier"])
func getBossWeight() -> float: return float(waveData["baseline"]["groupWeights"]["boss"])

# System Scaling Config
func getSystemCount() -> int: return int(waveData["baseline"]["systemScaling"]["systemCount"])
func getWavesPerSystem() -> int: return int(waveData["baseline"]["systemScaling"]["wavesPerSystem"])
func getSystemEnemyMultiplier() -> float: return float(waveData["baseline"]["systemScaling"]["enemyMultiplierPerSystem"])
func getTierTwoEnemyWaveThresh() -> float: return float(waveData["baseline"]["systemScaling"]["tierTwoWaveThresh"])
func getTierThreeEnemyWaveThresh() -> float: return float(waveData["baseline"]["systemScaling"]["tierThreeWaveThresh"])
func getScaledSystemEnemyMultiplier() -> float: return pow(getSystemEnemyMultiplier(), systemNumber - 1)

# Wave Scaling Config
func getHealthScalePerWave() -> float: return float(waveData["baseline"]["waveScaling"]["healthScalePerWave"])
func getDamageScalePerWave() -> float: return float(waveData["baseline"]["waveScaling"]["damageScalePerWave"])

# Difficulty Modifiers
func getLabel(level: int) -> String: return str(getDifficulty(level).get("label", ""))
func getEnemyCountMultiplier(level: int) -> float: return float(getDifficulty(level).get("enemy_count_multiplier", 1.0))
func getSystemTransitionTime(level: int) -> float: return float(getDifficulty(level).get("systemTransitionDurationSec", 1.0))
func getSpawnIntervalDecay(level: int) -> float: return float(getDifficulty(level).get("spawnIntervalDecayPerWave", 1.0))
func getIntermissionDuration(level: int) -> float: return float(getDifficulty(level).get("intermission_duration_sec", 10.0))

func getSpawnInterval(level: int, waveWithinSystem: int = 1) -> float:
	var base := float(getDifficulty(level).get("spawn_interval_sec", 1.0))
	var decay := getSpawnIntervalDecay(level)
	var floorInterval := getBaseSpawnInterval()
	var interval := base * pow(decay, waveWithinSystem - 1)
	return maxf(interval, floorInterval)

func getWaveCountScale(level: int, waveWithinSystem: int) -> float:
	var scale := float(getDifficulty(level).get("waveCountScalePerWave", 1.0))
	return pow(scale, waveWithinSystem - 1)


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
