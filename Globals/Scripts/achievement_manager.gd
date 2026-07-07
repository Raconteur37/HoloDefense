extends Node

const LOCAL_SAVE_PATH = "user://achievements.json"
const STEAM_FILE_NAME = "achievements_cloud.json"


var achievements: Dictionary = {
	"build_first_tower": false,
	"survive_wave_10": false,
	"unlock_hidden_faction": false,
	"initial_reset": false
}

func _ready() -> void:
	load_achievements()


	if not achievements["initial_reset"]:
		execute_initial_reset()

# Call this when the hardcoded logic for an achievement is met
func unlock_achievement(achievement_name: String) -> void:
	if achievements.has(achievement_name) and not achievements[achievement_name]:
		achievements[achievement_name] = true
		print("Achievement Unlocked: ", achievement_name)
		
		# Save state to files
		save_achievements()
		
		if Steam.isSteamRunning():
			Steam.setAchievement(achievement_name)
			Steam.storeStats()

func save_achievements() -> void:
	var json_string = JSON.stringify(achievements)
	
	# 1. Save Locally
	var file = FileAccess.open(LOCAL_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
	else:
		push_error("Failed to save achievements locally.")

	if Steam.isSteamRunning():
		var data_buffer = json_string.to_utf8_buffer()
		var success = Steam.fileWrite(STEAM_FILE_NAME, data_buffer, data_buffer.size())
		if not success:
			push_warning("Failed to write to Steam Cloud.")

func load_achievements() -> void:
	var json_string = ""

	if Steam.isSteamRunning() and Steam.fileExists(STEAM_FILE_NAME):
		var file_size = Steam.getFileSize(STEAM_FILE_NAME)
		var read_result = Steam.fileRead(STEAM_FILE_NAME, file_size)
		
		if read_result.has("buf") and read_result["ret"]:
			json_string = read_result["buf"].get_string_from_utf8()

	if json_string == "" and FileAccess.file_exists(LOCAL_SAVE_PATH):
		var file = FileAccess.open(LOCAL_SAVE_PATH, FileAccess.READ)
		if file:
			json_string = file.get_as_text()
			file.close()

	if json_string != "":
		var parsed_data = JSON.parse_string(json_string)
		if typeof(parsed_data) == TYPE_DICTIONARY:
			# Iterate and merge so we don't delete new achievements added in game updates
			for key in parsed_data.keys():
				if achievements.has(key):
					achievements[key] = parsed_data[key]

func is_unlocked(achievement_name: String) -> bool:
	if achievements.has(achievement_name):
		return achievements[achievement_name]
	
	# Helpful for debugging if you misspell an achievement name in another script
	push_warning("AchievementManager: Tried to check '%s', but it doesn't exist in the registry." % achievement_name)
	return false

func execute_initial_reset() -> void:
	print("AchievementManager: Initial reset flag is false. Wiping data...")
	
	# 1. CALL YOUR RESET LOGIC HERE
	XpManager.resetData()
	StatManager.resetStats()
	EconomyManager.reset()
	# e.g., XPManager.resetData()
	# e.g., StatsManager.hardResetAllSaveData()
	# e.g., EconomyManager.reset()
	
	# 2. Update the dictionary so it never happens again
	achievements["initial_reset"] = true
	
	# 3. Save the updated flag locally and to the Steam Cloud
	save_achievements()
	
	# Optional: If "initial_reset" is actually set up as a real achievement in your Steamworks backend, 
	# you can push it to Steam here as well:
	if Steam.isSteamRunning():
		Steam.setAchievement("initial_reset")
		Steam.storeStats()
