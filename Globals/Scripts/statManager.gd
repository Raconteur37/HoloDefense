extends Node


var wavesCompleted = 0
var enemiesKilled = 0
var elapsedTime

var startdustEarned
var stardustTotal

var tierOneEnemiesKilled = 0
var tierTwoEnemiesKilled = 0
var tierThreeEnemiesKilled = 0
var bossesKilled = 0
var turretsPlaced = 0
var citizensGenerated = 0
var researchCompleted = 0
var difficultyMultiplier = 0
var systemsCompleted = 0

var currentRun 

var currentStats = {} 

var save_path = "user://turret_stats.json"
var default_path = "res://Config/Turret Stats.json"

func _ready() -> void:
	loadStats()

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
	if FileAccess.file_exists(default_path):
		var default_file = FileAccess.open(default_path, FileAccess.READ)
		var content = default_file.get_as_text()
		default_file.close()
		
		var save_file = FileAccess.open(save_path, FileAccess.WRITE)
		save_file.store_string(content)
		save_file.close()
	else:
		push_error("Default stats file not found at: " + default_path)
		return # Stop here if there is no default to work with
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	json.parse(json_string)
	currentStats = json.data

func writeStatsToConfig():
	var json_string = JSON.stringify(currentStats, "\t")
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Stats saved successfully to: ", save_path)
	else:
		print("Failed to open file for saving.")

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
