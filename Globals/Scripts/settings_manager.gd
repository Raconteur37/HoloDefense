extends Node

# ─────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────
const LOCAL_SAVE_PATH = "user://settings.json"
const STEAM_SAVE_FILE = "settings_cloud.json"

# Add any new settings here! The script will automatically add missing
# keys to the player's save file the next time they boot the game.
var default_settings: Dictionary = {
	"Music": true,
	"Music Volume": 100,
	"SFX": true,
	"SFX Volume": 100,
	"tutorial_done": false,
	
	# We use a nested dictionary to track which enemies have been seen.
	# Keys will be String(enemy_id), Values will be true/false.
	"enemyInfo": {
	"basic_square" : false,
	"speedy_triangle": false,
	"tanky_rectangle": false,
	"shooty_diamond": false,
	"hexagon_mothership": false
	},
	"eliteInfo": {
	"steel" : false,
	"time_fractured": false,
	"summoner": false,
	"windy": false,
	"mending": false,
	"unstoppable": false,
	"paracasual": false
	},
	"codesRedeemed": {
	"awesomeel218": false,
	"superrare420": false,
	"ohemgee": false,
	"superduperdev!": false
	}
}

# The active dictionary used during gameplay
var current_settings: Dictionary = {}

func _ready() -> void:
	load_settings()

# ─────────────────────────────────────────
# CORE: GETTERS & SETTERS
# ─────────────────────────────────────────

## Use this to change a setting (e.g., SettingsManager.set_value("Music Volume", 80))
func set_value(key: String, value: Variant) -> void:
	if current_settings.has(key):
		current_settings[key] = value
		save_settings() # Auto-save whenever a value is changed
	else:
		push_error("SettingsManager: Tried to set unknown key: ", key)

## Use this to get a setting (e.g., SettingsManager.get_value("Music Volume"))
func get_value(key: String, default_val: Variant = null) -> Variant:
	return current_settings.get(key, default_val)


# ─────────────────────────────────────────
# ENEMY INFO SPECIFIC HELPERS
# ─────────────────────────────────────────

## Returns true if the enemy popup has already been shown.
func has_seen_enemy(enemy_id: int) -> bool:
	var enemy_str = Enemy.EnemyID.keys()[enemy_id].to_lower()
	
	if current_settings["enemyInfo"].has(enemy_str):
		return current_settings["enemyInfo"][enemy_str]
		
	return false

func has_seen_elite(elite_id: int) -> bool:
	var elite_str = Enemy.EliteType.keys()[elite_id].to_lower()
	
	if current_settings["eliteInfo"].has(elite_str):
		return current_settings["eliteInfo"][elite_str]
		
	return false

## Call this right after you show the popup so it never shows again.
func mark_enemy_seen(enemy_id: int) -> void:
	var enemy_str = Enemy.EnemyID.keys()[enemy_id].to_lower()
	
	current_settings["enemyInfo"][enemy_str] = true
	save_settings()

func mark_elite_seen(elite_id: int) -> void:
	var elite_str = Enemy.EliteType.keys()[elite_id].to_lower()
	
	current_settings["eliteInfo"][elite_str] = true
	save_settings()

# ─────────────────────────────────────────
# SAVE / LOAD LOGIC
# ─────────────────────────────────────────

func save_settings() -> void:
	var json_string = JSON.stringify(current_settings, "\t")
	var saved_to_steam = false
	
	# 1. Attempt to save to Steam Cloud first
	if SteamManager.steam_initialized:
		var bytes = json_string.to_utf8_buffer()
		# Steam fileWrite requires the filename, and the byte array data
		var success = Steam.fileWrite(STEAM_SAVE_FILE, bytes)
		if success:
			saved_to_steam = true
			# print("Saved settings to Steam Cloud successfully.")
	
	# 2. Always save locally as a reliable backup
	var file = FileAccess.open(LOCAL_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		if not saved_to_steam:
			# print("Saved settings locally.")
			pass
	else:
		push_error("SettingsManager: Failed to open local save path.")

func load_settings() -> void:
	var loaded_data = {}
	var loaded_from_steam = false
	
	# 1. Attempt to load from Steam Cloud
	if SteamManager.steam_initialized and Steam.fileExists(STEAM_SAVE_FILE):
		var file_size: int = Steam.getFileSize(STEAM_SAVE_FILE)
		var read_result: Dictionary = Steam.fileRead(STEAM_SAVE_FILE, file_size)
		if read_result.has("buf"):
			var json_string = read_result["buf"].get_string_from_utf8()
			var parsed = JSON.parse_string(json_string)
			if typeof(parsed) == TYPE_DICTIONARY:
				loaded_data = parsed
				loaded_from_steam = true
				# print("Loaded settings from Steam Cloud.")
				
	# 2. Fallback to Local Save if Steam isn't running / file is missing
	if not loaded_from_steam and FileAccess.file_exists(LOCAL_SAVE_PATH):
		var file = FileAccess.open(LOCAL_SAVE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			var parsed = JSON.parse_string(json_string)
			if typeof(parsed) == TYPE_DICTIONARY:
				loaded_data = parsed
				# print("Loaded settings from Local Storage.")
	
	# 3. Merge the loaded data with our defaults
	_merge_with_defaults(loaded_data)


# ─────────────────────────────────────────
# SCHEMA MERGING (Auto-updates old save files)
# ─────────────────────────────────────────

func _merge_with_defaults(loaded: Dictionary) -> void:
	# Start with a fresh copy of defaults
	current_settings = default_settings.duplicate(true)
	
	# Overwrite defaults with player's saved choices if they exist
	for key in loaded.keys():
		if current_settings.has(key):
			# If the key is a dictionary (like enemyInfo), merge the sub-keys individually
			if typeof(current_settings[key]) == TYPE_DICTIONARY and typeof(loaded[key]) == TYPE_DICTIONARY:
				for sub_key in loaded[key].keys():
					current_settings[key][sub_key] = loaded[key][sub_key]
			else:
				# Otherwise, just overwrite the value
				current_settings[key] = loaded[key]
				
	# Doing it this way ensures that if you add "Resolution": 1080 to default_settings later,
	# it is automatically injected into the player's old save file right here!
	
	# Save immediately to ensure the physical file is updated with any new missing keys
	save_settings()

# ─────────────────────────────────────────
# CODES REDEEMED HELPERS
# ─────────────────────────────────────────


func is_code_valid(code: String) -> bool:
	var code_lower = code.to_lower()
	return current_settings["codesRedeemed"].has(code_lower)


func has_redeemed_code(code: String) -> bool:
	var code_lower = code.to_lower()
	if current_settings["codesRedeemed"].has(code_lower):
		return current_settings["codesRedeemed"][code_lower]
	return false


func mark_tutorial_done() -> void:
	current_settings["tutorial_done"] = true
	save_settings()


func is_tutorial_done() -> bool:
	return current_settings.get("tutorial_done", false)

func redeem_code(code: String) -> bool:
	var code_lower = code.to_lower()
	
	# 1. Check if it's a real code
	if not current_settings["codesRedeemed"].has(code_lower):
		return false
		
	# 2. Check if they already claimed it
	if current_settings["codesRedeemed"][code_lower] == true:
		return false
		
	# 3. Mark as redeemed and save!
	current_settings["codesRedeemed"][code_lower] = true
	save_settings()
	return true
