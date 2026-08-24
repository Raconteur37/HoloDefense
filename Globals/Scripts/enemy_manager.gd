extends Node

var enemy_data: Dictionary = {}
var elite_data: Dictionary = {}

# New variables for cost tracking
var cost_multipliers_data: Dictionary = {}
var enemies_with_cost: Array[Enemy.EnemyID] = []

var enemyTextures = {
	Enemy.EnemyID.BASIC_SQUARE : "res://Textures/Enemies/Basic Square.png",
	Enemy.EnemyID.SPEEDY_TRIANGLE : "res://Textures/Enemies/triangle_enemy.png",
	Enemy.EnemyID.SHOOTY_DIAMOND : "res://Textures/Enemies/diamond_enemy.png",
	Enemy.EnemyID.HEXAGON_MOTHERSHIP : "res://Textures/Enemies/hexagon_enemy.png",
	Enemy.EnemyID.TANKY_RECTANGLE : "res://Textures/Enemies/rectangle_enemy.png",
	Enemy.EnemyID.PACKED_CIRCLE : "res://Textures/Enemies/circle_enemy.png",
	Enemy.EnemyID.DRILLING_CONE : "res://Textures/Enemies/cone_enemy.png"
}

func _ready() -> void:
	loadData()

func loadData():
	var file := FileAccess.open("res://Config/Enemy Info.json", FileAccess.READ)
	if file == null:
		push_error("EnemyInfo: could not open 'Enemy Info.json'")
		return

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err != OK:
		push_error("EnemyInfo: JSON parse error — %s" % json.get_error_message())
		return

	# Load Cost Multipliers and convert string keys to enums
	if json.data.has("costMultipliers") and json.data["costMultipliers"].size() > 0:
		var raw_multipliers = json.data["costMultipliers"][0]
		for key in raw_multipliers:
			var elite_enum = _elite_id_to_enum(key)
			cost_multipliers_data[elite_enum] = raw_multipliers[key]

	# Load Enemy Data and build the cost list
	for entry in json.data["enemies"]:
		var string_id = entry["id"]
		enemy_data[string_id] = entry
		
		# If the JSON entry has a cost, add its Enum ID to the list
		if entry.has("cost"):
			var enum_id = _id_to_enum(string_id)
			if enum_id != Enemy.EnemyID.NONE:
				enemies_with_cost.append(enum_id)
		
	# Load Elite Data (Stored inside an array at index 0 in the JSON)
	if json.data.has("elite") and json.data["elite"].size() > 0:
		elite_data = json.data["elite"][0]


# --- Helpers ---

func _get_enemy_texture(enemyID : Enemy.EnemyID):
	return load(enemyTextures.get(enemyID))

func _enum_to_id(enemy_id: Enemy.EnemyID) -> String:
	return Enemy.EnemyID.keys()[enemy_id].to_lower()

# Converts a string ID (like "basic_square") back to the enum (Enemy.EnemyID.BASIC_SQUARE)
func _id_to_enum(id_string: String) -> Enemy.EnemyID:
	for key in Enemy.EnemyID.keys():
		if key.to_lower() == id_string.to_lower():
			return Enemy.EnemyID[key]
	return Enemy.EnemyID.NONE

# Converts a string ID (like "steel") back to the elite enum
func _elite_id_to_enum(id_string: String) -> Enemy.EliteType:
	for key in Enemy.EliteType.keys():
		if key.to_lower() == id_string.to_lower():
			return Enemy.EliteType[key]
	push_error("EnemyInfo: No EliteType found for '%s'" % id_string)
	return Enemy.EliteType.values()[0] # Safe fallback to whatever the first enum value is


# --- Cost & Multiplier Getters ---

func get_all_cost_multipliers() -> Dictionary:
	return cost_multipliers_data

func get_elite_cost_multiplier(elite_type: Enemy.EliteType) -> float:
	# Directly look up the enum key. Returns 1.0 as a fallback if not found.
	return float(cost_multipliers_data.get(elite_type, 1.0)) 

func get_enemies_with_cost_list() -> Array[Enemy.EnemyID]:
	return enemies_with_cost

# Gets a specific enemy enum from the cost list based on the provided array index
func get_enemy_from_cost_list(index: int) -> Enemy.EnemyID:
	if index >= 0 and index < enemies_with_cost.size():
		return enemies_with_cost[index]
	push_error("EnemyInfo: Index %s out of bounds for enemies_with_cost array" % index)
	return Enemy.EnemyID.NONE
	
func get_enemy_cost(enemy_id: Enemy.EnemyID) -> int:
	return int(get_enemy(enemy_id).get("cost", 0))


# --- Enemy Getters ---

func get_enemy(enemy_id: Enemy.EnemyID) -> Dictionary:
	if enemy_id == Enemy.EnemyID.NONE:
		return {}
	var id := _enum_to_id(enemy_id)
	if not enemy_data.has(id):
		push_error("EnemyInfo: no enemy with id '%s'" % id)
		return {}
	return enemy_data[id]

func get_health(enemy_id: Enemy.EnemyID) -> int:
	return int(get_enemy(enemy_id).get("health", 0))

func get_enemy_name(enemy_id: Enemy.EnemyID) -> String:
	return String(get_enemy(enemy_id).get("name", "none"))

func get_damage(enemy_id: Enemy.EnemyID) -> int:
	return int(get_enemy(enemy_id).get("damage", 0))

func get_speed(enemy_id: Enemy.EnemyID) -> float:
	return float(get_enemy(enemy_id).get("speed", 0.0))

func get_attack_time(enemy_id: Enemy.EnemyID) -> float:
	return float(get_enemy(enemy_id).get("attackTime", 1.0))

func get_range(enemy_id: Enemy.EnemyID) -> float:
	return float(get_enemy(enemy_id).get("attackRange", 1.0))

func get_projectile_speed(enemy_id: Enemy.EnemyID) -> float:
	return float(get_enemy(enemy_id).get("projectileSpeed", 1.0))

func get_event_time(enemy_id: Enemy.EnemyID) -> float:
	return float(get_enemy(enemy_id).get("eventTime", 1.0))

func get_enemies_to_spawn(enemy_id: Enemy.EnemyID) -> float:
	return float(get_enemy(enemy_id).get("enemiesToSummon", 1.0))

func get_description(enemy_id: Enemy.EnemyID) -> String:
	return get_enemy(enemy_id).get("description")

func get_threat_level(enemy_id: Enemy.EnemyID) -> String:
	return get_enemy(enemy_id).get("threat_level")

func get_tier(enemy_id: Enemy.EnemyID) -> int:
	return int(get_enemy(enemy_id).get("tier", 1))

func get_minis_spawned(enemy_id: Enemy.EnemyID) -> int:
	return int(get_enemy(enemy_id).get("minis_spawned", 1))

func get_explosion_radius(enemy_id: Enemy.EnemyID) -> int:
	return int(get_enemy(enemy_id).get("explosion_radius", 1))

func get_drill_speed(enemy_id: Enemy.EnemyID):
	return int(get_enemy(enemy_id).get("drill_speed", 0.5))

# --- Elite Getters ---

func _elite_enum_to_id(elite_type: Enemy.EliteType) -> String:
	return Enemy.EliteType.keys()[elite_type].to_lower()

func get_elite_data(elite_type: Enemy.EliteType) -> Dictionary:
	var id := _elite_enum_to_id(elite_type)
	if not elite_data.has(id):
		# No error pushed here because some enums intentionally lack config data
		return {}
	return elite_data[id]

func get_elite_name(elite_type: Enemy.EliteType) -> String:
	return String(get_elite_data(elite_type).get("name", "Unknown Elite"))

func get_elite_description(elite_type: Enemy.EliteType) -> String:
	var data = get_elite_data(elite_type)
	if data.has("description"):
		return String(data.get("description", ""))
	elif data.has("descirption"): # Fallback for JSON typo
		return String(data.get("descirption", ""))
	return ""

# Steel
func get_elite_steel_damage_reduction() -> float:
	return float(get_elite_data(Enemy.EliteType.STEEL).get("damage_reduction", 0))

# Summoner
func get_elite_summoner_allies_summoned() -> int:
	return int(get_elite_data(Enemy.EliteType.SUMMONER).get("allies_summoned", 0))

func get_elite_summoner_spawn_interval() -> float:
	return float(get_elite_data(Enemy.EliteType.SUMMONER).get("spawn_interval", 0.0))

# Windy
func get_elite_windy_speed_increase() -> float:
	return float(get_elite_data(Enemy.EliteType.WINDY).get("speed_increase", 0.0))

# Mending
func get_elite_mending_heal_amount() -> float:
	return float(get_elite_data(Enemy.EliteType.MENDING).get("heal_amount", 0.0))

func get_elite_mending_heal_interval() -> float:
	return float(get_elite_data(Enemy.EliteType.MENDING).get("heal_interval", 0.0))

func get_elite_mending_heal_radius() -> float:
	return float(get_elite_data(Enemy.EliteType.MENDING).get("heal_radius", 0.0))

# Unstoppable
func get_absorbent_health_increase() -> float:
	return float(get_elite_data(Enemy.EliteType.UNSTOPPABLE).get("health_increase", 0.0))
