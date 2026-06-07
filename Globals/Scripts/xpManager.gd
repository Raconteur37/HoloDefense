extends Node

var turretXpData = {}
var save_path = "user://turret_xp_save.json"
var configData = {} 

func _ready():
	loadConfig()
	initialize_xp_tracking()
	addXp(Turret.TurretID.ARROW_TURRET)

func get_turret_string(id: Turret.TurretID) -> String:
	return Turret.TurretID.keys()[id].to_lower()

func initialize_xp_tracking():
	var turrets = configData.get("turret_xp", {}).keys()
	for turret in turrets:
		turretXpData[turret] = 0.0

func addXp(turret):
	turret = get_turret_string(turret)
	var xp_to_add = configData.get("turret_xp_gain", {}).get(turret, 0.0)
	if turretXpData.has(turret):
		turretXpData[turret] += xp_to_add

	check_level_up(turret)

func check_level_up(turret):
	# Logic to compare turret_xp_data[turret] against 
	# config_data["xp_maximum"] based on the turret's rarity
	pass

func saveXpData():
	# Convert the live progress dictionary to a JSON string
	var json_string = JSON.stringify(turretXpData, "\t")
	
	# Write the string to the persistent user folder
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("XP save successful: ", save_path)
	else:
		push_error("Failed to save XP data! Error code: " + str(FileAccess.get_open_error()))

func loadConfig():
	var config_path = "res://Config/TurretXP.json"
	if FileAccess.file_exists(config_path):
		var file = FileAccess.open(config_path, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		
		if error == OK:
			configData = json.data
			print("Config loaded successfully.")
		else:
			push_error("Failed to parse JSON config.")
	else:
		push_error("Config file not found at " + config_path)
