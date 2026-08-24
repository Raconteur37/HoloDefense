extends Node

const BASE_SAVE_FILE_NAME = "achievements.json"
const STEAM_FILE_NAME = "achievements_cloud.json"
const CONFIG_PATH = "res://Config/Achievements.json" # Make sure your JSON file is saved here!

# This holds the true/false save state for the player
var achievements: Dictionary = {
	"initial_reset": false
}

# This holds the read-only config data (titles, descriptions, rewards)
var achievement_metadata: Dictionary = {}

func _ready() -> void:
	load_config()
	load_achievements()

	if not achievements["initial_reset"]:
		execute_initial_reset()

# Generate a unique local path based on whether Steam is running
func get_local_save_path() -> String:
	if Engine.has_singleton("Steam") and Steam.loggedOn():
		var steam_id: int = Steam.getSteamID()
		return "user://achievements_%s.json" % str(steam_id)
	else:
		# Fallback for non-Steam builds or if Steam is completely offline
		return "user://" + BASE_SAVE_FILE_NAME

# ----------------- Configuration & Initialization -----------------

func load_config() -> void:
	if FileAccess.file_exists(CONFIG_PATH):
		var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		
		if error == OK and json.data is Dictionary:
			achievement_metadata = json.data
			
			# Dynamically register all achievements from the config into the save state
			for key in achievement_metadata.keys():
				if not achievements.has(key):
					achievements[key] = false
		else:
			push_error("AchievementManager: Failed to parse achievement config JSON.")
	else:
		push_error("AchievementManager: Config file not found at " + CONFIG_PATH)

# ----------------- Core Unlock Logic -----------------

func unlock_achievement(achievement_name: String) -> void:
	if achievements.has(achievement_name) and not achievements[achievement_name]:
		achievements[achievement_name] = true
		print("Achievement Unlocked: ", achievement_name)
		
		# 1. Grant any rewards associated with this achievement
		_grant_reward(achievement_name)
		
		# 2. Save state to files
		save_achievements()
		
		# 3. Push to Steam
		if Steam.isSteamRunning():
			Steam.setAchievement(achievement_name)
			Steam.storeStats()

func _grant_reward(achievement_name: String) -> void:
	if not achievement_metadata.has(achievement_name):
		return
		
	var data = achievement_metadata[achievement_name]
	var reward_type = data.get("reward_type", "")
	var reward_id = data.get("reward_id", "")
	var reward_amount = data.get("reward_amount", "")
	
	var achievementGetScene = load("res://Game Scenes/Achievement Get.tscn").instantiate()
	get_tree().current_scene.add_child(achievementGetScene)
	achievementGetScene.buildAchievementBar(data.get("title"),data.get("description"),data.get("icon_path"),5)

	
	match reward_type:
		"turret":
			var turret_enum_id = TurretManager.getTurretIdFromString(reward_id)
			EconomyManager.unlock_turret(turret_enum_id)
			print("Granted achievement reward: Turret unlocked - ", reward_id)
			
		"stardust":
			# Example of how you could easily add stardust rewards later
			EconomyManager.add_stardust(int(reward_id))
			print("Granted achievement reward: Stardust - ", reward_id)
		
		"shard":
			EconomyManager.add_shards(reward_id,int(reward_amount))
			EconomyManager.save_economy()
		
		_:
			# No reward type specified, or unrecognized
			pass

# ----------------- Save / Load System -----------------

func save_achievements() -> void:
	var json_string = JSON.stringify(achievements)
	var local_path = get_local_save_path()
	
	# 1. Save Locally
	var file = FileAccess.open(local_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
	else:
		push_error("AchievementManager: Failed to save achievements locally.")

	# 2. Save to Steam Cloud
	if Steam.isSteamRunning():
		var data_buffer = json_string.to_utf8_buffer()
		var success = Steam.fileWrite(STEAM_FILE_NAME, data_buffer, data_buffer.size())
		if not success:
			push_warning("AchievementManager: Failed to write to Steam Cloud.")

func load_achievements() -> void:
	var json_string = ""
	var local_path = get_local_save_path()
	var legacy_path = "user://" + BASE_SAVE_FILE_NAME
	
	# --- LEGACY SAVE MIGRATION ---
	if local_path != legacy_path and not FileAccess.file_exists(local_path) and FileAccess.file_exists(legacy_path):
		var err = DirAccess.copy_absolute(legacy_path, local_path)
		if err == OK:
			print("AchievementManager: Successfully migrated legacy save to %s" % local_path)
		else:
			push_error("AchievementManager: Failed to migrate legacy save! Error code: %s" % err)
	# -----------------------------

	# Check Steam Cloud first
	if Steam.isSteamRunning() and Steam.fileExists(STEAM_FILE_NAME):
		var file_size = Steam.getFileSize(STEAM_FILE_NAME)
		var read_result = Steam.fileRead(STEAM_FILE_NAME, file_size)
		
		if read_result.has("buf") and read_result["ret"]:
			json_string = read_result["buf"].get_string_from_utf8()

	# Fallback to local save
	if json_string == "" and FileAccess.file_exists(local_path):
		var file = FileAccess.open(local_path, FileAccess.READ)
		if file:
			json_string = file.get_as_text()
			file.close()

	# Apply save data
	if json_string != "":
		var parsed_data = JSON.parse_string(json_string)
		if typeof(parsed_data) == TYPE_DICTIONARY:
			# Iterate and merge so we only update valid config keys (and initial_reset)
			for key in parsed_data.keys():
				if achievements.has(key):
					achievements[key] = parsed_data[key]

# ----------------- Helper / Utility Functions -----------------

func is_unlocked(achievement_name: String) -> bool:
	if achievements.has(achievement_name):
		return achievements[achievement_name]
	
	push_warning("AchievementManager: Tried to check '%s', but it doesn't exist in the registry." % achievement_name)
	return false

func get_achievement_data(achievement_name: String) -> Dictionary:
	# Use this from your UI scripts to grab the title, description, and icon path!
	if achievement_metadata.has(achievement_name):
		return achievement_metadata[achievement_name]
	return {}

func execute_initial_reset() -> void:
	print("AchievementManager: Initial reset flag is false. Wiping data...")
	
	XpManager.resetData()
	StatManager.resetStats()
	EconomyManager.reset()
	
	achievements["initial_reset"] = true
	save_achievements()
	
	if Steam.isSteamRunning():
		Steam.setAchievement("initial_reset")
		Steam.storeStats()
