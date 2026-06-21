extends Node

const SAVE_FILE_NAME := "economy.json"
const LOCAL_SAVE_PATH := "user://" + SAVE_FILE_NAME

var economy_data: Dictionary = {}
var economy_loaded_successfully: bool = false

signal economy_loaded
signal economy_saved
signal stardust_changed(new_value: int)
signal currency_changed(category: String, key: String, new_value: int)
signal turret_unlocked_signal(turret_id) # <--- ADD THIS LINE

func _ready() -> void:
	load_economy()

func get_default_economy() -> Dictionary:
	var turret_keys = [
		"arrow_turret", "mini_sentry_turret", "energizer_turret", 
		"railgun_turret", "flame_turret", "reaper_turret", 
		"royal_turret", "firework_turret", "tesla_turret", 
		"sentry_turret", "gold_mine_turret", "seismic_turret", 
		"spider_turret", "voodoo_turret", "zombie_turret", 
		"medic_turret", "bubble_turret", "boomerang_turret"
	]
	
	var turret_defaults = {}
	for t in turret_keys:
		if t == "arrow_turret":
			turret_defaults[t] = 1
		else:
			turret_defaults[t] = 0
		
	return {
		"stardust": 0,
		"turret_shards": turret_defaults.duplicate(),
		"shards": {
			"common_turret": 0, "rare_turret": 0, "super_rare_turret": 0,
			"legendary_turret": 0, "unseen_turret": 0, "unstable": 0
		},
		"shard_fragments": {
			"common_turret": 0, "rare_turret": 0, "super_rare_turret": 0,
			"legendary_turret": 0, "unseen_turret": 0, "unstable": 0
		},
		"turrets_unlocked": turret_defaults.duplicate()
	}

func merge_with_defaults(loaded: Dictionary) -> Dictionary:
	var merged: Dictionary = get_default_economy()
	
	if loaded.has("stardust") and typeof(loaded["stardust"]) == TYPE_INT:
		merged["stardust"] = loaded["stardust"]
	
	for category in ["turret_shards", "shards", "shard_fragments", "turrets_unlocked"]:
		if loaded.has(category) and typeof(loaded[category]) == TYPE_DICTIONARY:
			for key in loaded[category].keys():
				if merged[category].has(key):
					merged[category][key] = loaded[category][key]
	return merged

# ---------------- Load/Save ----------------
func load_economy() -> void:
	var loaded_dict: Dictionary = {}
	var found_save := false

	if Engine.has_singleton("Steam"):
		if Steam.isCloudEnabledForAccount() and Steam.isCloudEnabledForApp():
			if Steam.fileExists(SAVE_FILE_NAME):
				var file_size: int = Steam.getFileSize(SAVE_FILE_NAME)
				if file_size > 0:
					var read_result: Dictionary = Steam.fileRead(SAVE_FILE_NAME, file_size)
					if read_result.get("ret", 0) > 0:
						var json_string: String = read_result["buf"].get_string_from_utf8()
						var parsed = JSON.parse_string(json_string)
						if parsed is Dictionary:
							loaded_dict = parsed
							found_save = true
							print("EconomyManager: loaded save from Steam Cloud")

	if not found_save and FileAccess.file_exists(LOCAL_SAVE_PATH):
		var file := FileAccess.open(LOCAL_SAVE_PATH, FileAccess.READ)
		if file:
			var json_string := file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(json_string)
			if parsed is Dictionary:
				loaded_dict = parsed
				found_save = true
				print("EconomyManager: loaded save from local disk")

	economy_data = merge_with_defaults(loaded_dict) if found_save else get_default_economy()

	if not found_save:
		print("EconomyManager: no save found, starting fresh — writing baseline file")
		save_economy()  # <-- the fix: actually persist the default the first time

	economy_loaded_successfully = true
	economy_loaded.emit()

func save_economy() -> void:
	var json_string := JSON.stringify(economy_data)

	var file := FileAccess.open(LOCAL_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("EconomyManager: saved locally to %s" % LOCAL_SAVE_PATH)
	else:
		push_error("EconomyManager: failed to open local save file for writing")

	if Engine.has_singleton("Steam"):
		if Steam.isCloudEnabledForAccount() and Steam.isCloudEnabledForApp():
			var buffer := json_string.to_utf8_buffer()
			var success: bool = Steam.fileWrite(SAVE_FILE_NAME, buffer, buffer.size())
			if success:
				print("EconomyManager: saved to Steam Cloud")
			else:
				push_error("EconomyManager: Steam Cloud write failed")
		else:
			print("EconomyManager: Steam Cloud disabled by user, local-only save")

	economy_saved.emit()

# ---------------- Turret Unlock API ----------------

func is_turret_unlocked(turret_id) -> bool:
	var turret_name = idToName(turret_id)
	return economy_data["turrets_unlocked"].get(turret_name, 0) == 1

func unlock_turret(turret_id) -> void:
	var turret_name = idToName(turret_id)
	if economy_data["turrets_unlocked"].has(turret_name):
		# Prevent double-unlocks just in case
		if economy_data["turrets_unlocked"][turret_name] == 0:
			economy_data["turrets_unlocked"][turret_name] = 1
			currency_changed.emit("turrets_unlocked", turret_name, 1)
			
			# Tell the rest of the game a turret was unlocked!
			turret_unlocked_signal.emit(turret_id)
			
			# Automatically save the game so they don't lose the unlock
			save_economy()

# ---------------- Helper Methods ----------------

func idToName(turretID: Turret.TurretID) -> String:
	return Turret.TurretID.keys()[turretID].to_lower()

func add_to_category(category: String, key: String, amount: int) -> void:
	if amount <= 0: return
	if not economy_data[category].has(key): return
	economy_data[category][key] += amount
	currency_changed.emit(category, key, economy_data[category][key])

func spend_from_category(category: String, key: String, amount: int) -> bool:
	if amount <= 0: return true
	if not economy_data[category].has(key) or economy_data[category][key] < amount: return false
	economy_data[category][key] -= amount
	currency_changed.emit(category, key, economy_data[category][key])
	return true

func get_turret_shards(turret_id) -> int:
	var turret_name = idToName(turret_id)
	return economy_data["turret_shards"].get(turret_name, 0)

func add_turret_shards(turret_id, amount: int) -> void:
	var turret_name = idToName(turret_id)
	add_to_category("turret_shards", turret_name, amount)

func spend_turret_shards(turret_id, amount: int) -> bool:
	var turret_name = idToName(turret_id)
	return spend_from_category("turret_shards", turret_name, amount)

# ---------------- Shards API ----------------

func get_shards(rarity: String) -> int:
	return economy_data["shards"].get(rarity, 0)

func add_shards(rarity: String, amount: int) -> void:
	add_to_category("shards", rarity, amount)

func spend_shards(rarity: String, amount: int) -> bool:
	return spend_from_category("shards", rarity, amount)

# ---------------- Shard Fragments API ----------------

func get_shard_fragments(rarity: String) -> int:
	return economy_data["shard_fragments"].get(rarity, 0)

func add_shard_fragments(rarity: String, amount: int) -> void:
	add_to_category("shard_fragments", rarity, amount)

func spend_shard_fragments(rarity: String, amount: int) -> bool:
	return spend_from_category("shard_fragments", rarity, amount)
