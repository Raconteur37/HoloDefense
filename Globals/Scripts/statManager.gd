extends Node

var wavesCompleted = 0
var enemiesKilled = 0
var elapsedTime = 0
var startdustEarned = 0
var stardustTotal = 0
var tierOneEnemiesKilled = 0
var tierTwoEnemiesKilled = 0
var tierThreeEnemiesKilled = 0
var bossesKilled = 0
var turretsPlaced = 0
var citizensGenerated = 0
var researchCompleted = 0
var difficultyMultiplier = 0
var systemsCompleted = 0
var basicSquaresKilled = 0
var speedyTrianglesKilled = 0
var shootyDiamondsKilled = 0
var tankyRectanglesKilled = 0
var hexagonMothershipsKilled = 0
var packedCirclesKilled = 0
var miniPackedCirclesKilled = 0
var currentRun 
var currentStats = {} 

var miniSentryKillsThisRun = 0
var highestResearchLevel = 0

const BASE_TURRET_STATS_FILE = "turret_stats.json"
const DEFAULT_TURRET_PATH = "res://Config/Turret Stats.json"
const TURRET_STATS_CLOUD_FILENAME = "turret_stats.json" # Steam Cloud filename, no path needed

var lifetimeStats = {}
const BASE_LIFETIME_STATS_FILE = "lifetime_stats.json"
const LIFETIME_STATS_CLOUD_FILENAME = "lifetime_stats.json" # Steam Cloud filename, no path needed

func _ready() -> void:
	loadStats()
	loadLifetimeStats()

# Generate a unique local path based on whether Steam is running
func get_turret_save_path() -> String:
	if Engine.has_singleton("Steam") and Steam.loggedOn():
		var steam_id: int = Steam.getSteamID()
		return "user://turret_stats_%s.json" % str(steam_id)
	else:
		return "user://" + BASE_TURRET_STATS_FILE

func get_lifetime_save_path() -> String:
	if Engine.has_singleton("Steam") and Steam.loggedOn():
		var steam_id: int = Steam.getSteamID()
		return "user://lifetime_stats_%s.json" % str(steam_id)
	else:
		return "user://" + BASE_LIFETIME_STATS_FILE

func get_turret_string(id: Turret.TurretID) -> String:
	return Turret.TurretID.keys()[id].to_lower()

func resetStatsConfig():
	currentStats = {}

func addStat(turret, statName, statValue):
	turret = get_turret_string(turret)
	
	if not currentStats.has(turret):
		currentStats[turret] = {}
		
	if not currentStats[turret].has(statName):
		currentStats[turret][statName] = 0
		
	currentStats[turret][statName] += statValue

func loadStats():
	var json_string = ""
	var loaded_from_cloud = false
	
	var save_path = get_turret_save_path()
	var legacy_path = "user://" + BASE_TURRET_STATS_FILE

	# --- LEGACY SAVE MIGRATION ---
	if save_path != legacy_path and not FileAccess.file_exists(save_path) and FileAccess.file_exists(legacy_path):
		var err = DirAccess.copy_absolute(legacy_path, save_path)
		if err == OK:
			print("StatManager: Successfully migrated legacy turret stats save to %s" % save_path)
		else:
			push_error("StatManager: Failed to migrate legacy turret stats save! Error code: %s" % err)
	# -----------------------------

	if Engine.has_singleton("Steam") and Steam.isCloudEnabledForAccount() and Steam.isCloudEnabledForApp() and Steam.fileExists(TURRET_STATS_CLOUD_FILENAME):
		var file_size = Steam.getFileSize(TURRET_STATS_CLOUD_FILENAME)
		var result = Steam.fileRead(TURRET_STATS_CLOUD_FILENAME, file_size)
		if result["ret"] > 0:
			json_string = result["buf"].get_string_from_utf8()
			loaded_from_cloud = true
	
	if not loaded_from_cloud:
		if not FileAccess.file_exists(save_path):
			if FileAccess.file_exists(DEFAULT_TURRET_PATH):
				var default_file = FileAccess.open(DEFAULT_TURRET_PATH, FileAccess.READ)
				var content = default_file.get_as_text()
				default_file.close()
				
				var save_file = FileAccess.open(save_path, FileAccess.WRITE)
				save_file.store_string(content)
				save_file.close()
			else:
				push_error("Default stats file not found at: " + DEFAULT_TURRET_PATH)
				return
		
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			json_string = file.get_as_text()
			file.close()
	
	var json = JSON.new()
	var parse_error = json.parse(json_string)
	
	if parse_error == OK and json.data is Dictionary:
		currentStats = json.data
		backfillMissingTurretStats()
	else:
		push_error("Failed to parse turret stats save file, " + save_path + " may be corrupted.")

func backfillMissingTurretStats():
	if not FileAccess.file_exists(DEFAULT_TURRET_PATH):
		return
	
	var default_file = FileAccess.open(DEFAULT_TURRET_PATH, FileAccess.READ)
	var default_json_string = default_file.get_as_text()
	default_file.close()
	
	var default_json = JSON.new()
	if default_json.parse(default_json_string) != OK or not default_json.data is Dictionary:
		return
	
	var defaults = default_json.data
	var changed = false
	
	for turret_key in defaults.keys():
		if not currentStats.has(turret_key):
			currentStats[turret_key] = defaults[turret_key]
			changed = true
		else:
			for stat_key in defaults[turret_key].keys():
				if not currentStats[turret_key].has(stat_key):
					currentStats[turret_key][stat_key] = defaults[turret_key][stat_key]
					changed = true
	
	if changed:
		writeTurretStatsToConfig()

func writeTurretStatsToConfig(): 
	var json_string = JSON.stringify(currentStats, "\t")
	var save_path = get_turret_save_path()
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Stats saved successfully to: ", save_path)
	else:
		print("Failed to open file for saving.")
		return
	
	# Also push to Steam Cloud if it's available and enabled
	if Engine.has_singleton("Steam") and Steam.isCloudEnabledForAccount() and Steam.isCloudEnabledForApp():
		var data := json_string.to_utf8_buffer()
		var success = Steam.fileWrite(TURRET_STATS_CLOUD_FILENAME, data, data.size())
		if success:
			print("Turret stats synced to Steam Cloud")
		else:
			push_error("Steam Cloud write failed for turret stats")

func reset():
	wavesCompleted = 0
	enemiesKilled = 0
	elapsedTime = 0
	startdustEarned = 0
	stardustTotal = 0
	tierOneEnemiesKilled = 0
	tierTwoEnemiesKilled = 0
	tierThreeEnemiesKilled = 0
	bossesKilled = 0
	turretsPlaced = 0
	citizensGenerated = 0
	researchCompleted = 0
	difficultyMultiplier = 0
	systemsCompleted = 0
	miniPackedCirclesKilled = 0
	packedCirclesKilled = 0
	basicSquaresKilled = 0
	speedyTrianglesKilled = 0
	shootyDiamondsKilled = 0
	hexagonMothershipsKilled = 0
	
	miniSentryKillsThisRun = 0

func getDefaultLifetimeStats() -> Dictionary: 
	return {
		"wavesCompleted": 0,
		"enemiesKilled": 0,
		"stardustEarned": 0,
		"tierOneEnemiesKilled": 0,
		"tierTwoEnemiesKilled": 0,
		"tierThreeEnemiesKilled": 0,
		"bossesKilled": 0,
		"packedCirclesKilled": 0,
		"miniPackedCirclesKilled": 0,
		"basicSquaresKilled": 0,
		"speedyTrianglesKilled": 0,
		"shootyDiamondsKilled": 0,
		"hexagonMothershipsKilled": 0,
		"tankyRectanglesKilled": 0,
		"turretsPlaced": 0,
		"citizensGenerated": 0,
		"researchCompleted": 0,
		"systemsCompleted": 0,
		"totalRuns": 0,
	}

func loadLifetimeStats():
	var json_string = ""
	var loaded_from_cloud = false
	
	var save_path = get_lifetime_save_path()
	var legacy_path = "user://" + BASE_LIFETIME_STATS_FILE

	# --- LEGACY SAVE MIGRATION ---
	if save_path != legacy_path and not FileAccess.file_exists(save_path) and FileAccess.file_exists(legacy_path):
		var err = DirAccess.copy_absolute(legacy_path, save_path)
		if err == OK:
			print("StatManager: Successfully migrated legacy lifetime stats save to %s" % save_path)
		else:
			push_error("StatManager: Failed to migrate legacy lifetime stats save! Error code: %s" % err)
	# -----------------------------

	if Engine.has_singleton("Steam") and Steam.isCloudEnabledForAccount() and Steam.isCloudEnabledForApp() and Steam.fileExists(LIFETIME_STATS_CLOUD_FILENAME):
		var file_size = Steam.getFileSize(LIFETIME_STATS_CLOUD_FILENAME)
		var result = Steam.fileRead(LIFETIME_STATS_CLOUD_FILENAME, file_size)
		if result["ret"] > 0:
			json_string = result["buf"].get_string_from_utf8()
			loaded_from_cloud = true
	
	if not loaded_from_cloud:
		if not FileAccess.file_exists(save_path):
			lifetimeStats = getDefaultLifetimeStats()
			saveLifetimeStats() 
			return
		
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			json_string = file.get_as_text()
			file.close()
	
	var json = JSON.new()
	var parse_error = json.parse(json_string)
	
	if parse_error == OK and json.data is Dictionary:
		lifetimeStats = json.data
		var defaults = getDefaultLifetimeStats()
		for key in defaults.keys():
			if not lifetimeStats.has(key):
				lifetimeStats[key] = defaults[key]
	else:
		push_error("Failed to parse lifetime stats file, resetting to defaults.")
		lifetimeStats = getDefaultLifetimeStats()

func saveLifetimeStats():
	var json_string = JSON.stringify(lifetimeStats, "\t")
	var save_path = get_lifetime_save_path()
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Lifetime stats saved successfully to: ", save_path)
	else:
		print("Failed to open file for saving lifetime stats.")
		return
	
	if Engine.has_singleton("Steam") and Steam.isCloudEnabledForAccount() and Steam.isCloudEnabledForApp():
		var data := json_string.to_utf8_buffer()
		var success = Steam.fileWrite(LIFETIME_STATS_CLOUD_FILENAME, data, data.size())
		if success:
			print("Lifetime stats synced to Steam Cloud")
		else:
			push_error("Steam Cloud write failed for lifetime stats")

func commitRunToLifetimeStats():
	lifetimeStats["wavesCompleted"] += wavesCompleted
	lifetimeStats["enemiesKilled"] += enemiesKilled
	lifetimeStats["stardustEarned"] += startdustEarned
	lifetimeStats["tierOneEnemiesKilled"] += tierOneEnemiesKilled
	lifetimeStats["tierTwoEnemiesKilled"] += tierTwoEnemiesKilled
	lifetimeStats["tierThreeEnemiesKilled"] += tierThreeEnemiesKilled
	lifetimeStats["bossesKilled"] += bossesKilled
	lifetimeStats["turretsPlaced"] += turretsPlaced
	lifetimeStats["citizensGenerated"] += citizensGenerated
	lifetimeStats["researchCompleted"] += researchCompleted
	lifetimeStats["systemsCompleted"] += systemsCompleted
	
	lifetimeStats["basicSquaresKilled"] += basicSquaresKilled
	lifetimeStats["speedyTrianglesKilled"] += speedyTrianglesKilled
	lifetimeStats["shootyDiamondsKilled"] += shootyDiamondsKilled
	lifetimeStats["hexagonMothershipsKilled"] += hexagonMothershipsKilled
	lifetimeStats["packedCirclesKilled"] += packedCirclesKilled
	lifetimeStats["miniPackedCirclesKilled"] += miniPackedCirclesKilled
	
	lifetimeStats["totalRuns"] += 1
	
	writeTurretStatsToConfig()
	saveLifetimeStats()

func getLifetimeStat(statName: String):
	if lifetimeStats.has(statName):
		return lifetimeStats[statName]
	push_error("Lifetime stat not found: " + statName)
	return null

func incrementLifetimeStat(statName: String, amount: int = 1) -> void:
	if lifetimeStats.has(statName):
		lifetimeStats[statName] += amount
		saveLifetimeStats()
	else:
		push_error("Lifetime stat not found: " + statName)

func getTurretStats(turretID: Turret.TurretID) -> Dictionary:
	var turret_key = get_turret_string(turretID)
	
	if currentStats.has(turret_key):
		return currentStats[turret_key].duplicate(true)
	else:
		return {}

func resetStats():
	reset() 
	
	resetStatsConfig() 
	backfillMissingTurretStats() 
	writeTurretStatsToConfig() 
	
	lifetimeStats = getDefaultLifetimeStats() 
	saveLifetimeStats() 
	
	print("All run, turret, and lifetime stats have been wiped completely!")
