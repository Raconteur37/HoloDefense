extends Node

var turretXpData = {}
var savePath = "user://turret_xp_save.json"
const steamFileName = "turret_xp_save_cloud.json"
var configData = {} 

func _ready():
	loadConfig()
	initializeXpTracking()
	loadXpData()
	saveXpData()

func getTurretString(id: Turret.TurretID) -> String:
	return Turret.TurretID.keys()[id].to_lower()

func initializeXpTracking():
	var turrets = configData.get("turret_xp_gain", {}).keys()
	for turret in turrets:
		turretXpData[turret] = {
			"xp": 0.0,
			"level": 1 
		}

func getMaxXp(rarity: String, level: int) -> float:
	var raritySettings = configData.get("xp_maximum", {}).get(rarity.to_lower(), {})
	
	if raritySettings.is_empty():
		push_warning("XP Manager: Rarity '%s' not found in config data." % rarity)
		return 0.0

	match level:
		2:
			return float(raritySettings.get("LevelTwoMaxXP", 0.0))
		3:
			return float(raritySettings.get("LevelThreeMaxXP", 0.0))
		_:
			return -1.0

func addXp(turret):
	turret = getTurretString(turret)
	var xpToAdd = configData.get("turret_xp_gain", {}).get(turret, 0.0)
	
	if turretXpData.has(turret):
		turretXpData[turret]["xp"] += xpToAdd

	checkLevelUp(turret)

func checkLevelUp(turretStr: String) -> void:
	if not turretXpData.has(turretStr):
		return

	var currentXp = turretXpData[turretStr]["xp"]
	var currentLevel = turretXpData[turretStr]["level"]
	
	var rarity = TurretManager.getTurretStat(TurretManager.getTurretIdFromString(turretStr), "rarity")
	
	# Ask for the XP required for the NEXT level
	var maxXp = getMaxXp(rarity, currentLevel + 1)
	var leveledUp = false

	while maxXp > 0.0 and currentXp >= maxXp:
		turretXpData[turretStr]["level"] += 1
		currentLevel = turretXpData[turretStr]["level"]
		leveledUp = true
		
		# Update maxXp for the NEW next level to check the loop condition again
		maxXp = getMaxXp(rarity, currentLevel + 1)

	if leveledUp:
		print(turretStr + " leveled up to " + str(currentLevel) + "!")
		saveXpData()
func incrementLevel(turret) -> void:
	var turretStr = getTurretString(turret)
	
	if turretXpData.has(turretStr):
		turretXpData[turretStr]["level"] += 1
		saveXpData()
		print(turretStr + " forced to level " + str(turretXpData[turretStr]["level"]))
	else:
		push_warning("XP Manager: Tried to increment unknown turret '%s'" % turretStr)

func saveXpData():
	var jsonString = JSON.stringify(turretXpData, "\t")
	
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	if file:
		file.store_string(jsonString)
		file.close()
		print("Local XP save successful: ", savePath)
	else:
		push_error("Failed to save local XP data! Error code: " + str(FileAccess.get_open_error()))

	if Steam.isSteamRunning():
		var dataBuffer = jsonString.to_utf8_buffer()
		var success = Steam.fileWrite(steamFileName, dataBuffer, dataBuffer.size())
		if success:
			print("Steam Cloud XP save successful.")
		else:
			push_warning("Failed to write XP data to Steam Cloud.")

func loadConfig():
	var configPath = "res://Config/TurretXP.json"
	if FileAccess.file_exists(configPath):
		var file = FileAccess.open(configPath, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		
		if error == OK:
			configData = json.data
			print("Config loaded successfully.")
		else:
			push_error("Failed to parse JSON config.")
	else:
		push_error("Config file not found at " + configPath)

func loadXpData():
	var jsonString = ""

	if Steam.isSteamRunning() and Steam.fileExists(steamFileName):
		var fileSize = Steam.getFileSize(steamFileName)
		var readResult = Steam.fileRead(steamFileName, fileSize)
		
		if readResult.has("buf") and readResult["ret"]:
			jsonString = readResult["buf"].get_string_from_utf8()

	if jsonString == "" and FileAccess.file_exists(savePath):
		var file = FileAccess.open(savePath, FileAccess.READ)
		if file:
			jsonString = file.get_as_text()
			file.close()

	if jsonString != "":
		var parsedData = JSON.parse_string(jsonString)
		if typeof(parsedData) == TYPE_DICTIONARY:
			for key in parsedData.keys():
				if turretXpData.has(key):
					if typeof(parsedData[key]) == TYPE_DICTIONARY:
						turretXpData[key]["xp"] = parsedData[key].get("xp", 0.0)
						turretXpData[key]["level"] = parsedData[key].get("level", 1)
					else:
						turretXpData[key]["xp"] = parsedData[key]
						turretXpData[key]["level"] = 1
			print("XP and Level data loaded successfully.")

func getCurrentXp(turret) -> float:
	var turretStr = getTurretString(turret)
	if turretXpData.has(turretStr):
		return turretXpData[turretStr]["xp"]
	
	push_warning("XP Manager: Tried to get XP for unknown turret '%s'" % turretStr)
	return 0.0

func getCurrentLevel(turret) -> int:
	var turretStr = getTurretString(turret)
	if turretXpData.has(turretStr):
		return turretXpData[turretStr]["level"]
		
	push_warning("XP Manager: Tried to get Level for unknown turret '%s'" % turretStr)
	return 1

func resetData() -> void:
	initializeXpTracking()
	
	saveXpData()
	
	print("All XP and Level data has been completely reset to 0.")
