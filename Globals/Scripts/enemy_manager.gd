extends Node

var enemy_data: Dictionary = {}

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

	for entry in json.data["enemies"]:
		enemy_data[entry["id"]] = entry

func _enum_to_id(enemy_id: Enemy.EnemyID) -> String:
	return Enemy.EnemyID.keys()[enemy_id].to_lower()

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
