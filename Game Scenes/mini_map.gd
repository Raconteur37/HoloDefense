extends Panel

@export var minimap_size: Vector2 = Vector2(200, 200)
@export var world_radius: float = 1200.0
@export var dot_size: float = 3.0

var enemy_color := Color(1.0, 0.988, 0.987, 0.9)
var center_color := Color(0.2, 0.8, 1.0, 0.8)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var center := minimap_size / 2
	var viewport_size := get_viewport().get_visible_rect().size
	var world_center := viewport_size / 2

	draw_rect(Rect2(Vector2.ZERO, minimap_size), Color(0.05, 0.1, 0.15, 0.85))
	draw_rect(Rect2(Vector2.ZERO, minimap_size), Color(0.0, 0.78, 0.79, 0.6), false, 1.5)
	draw_circle(center, 4.0, center_color)

	var allEnemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in allEnemies:
		if not is_instance_valid(enemy):
			continue
		var world_pos: Vector2 = enemy.global_position - world_center
		var normalized := Vector2(
			world_pos.x / (viewport_size.x / 2),
			world_pos.y / (viewport_size.y / 2)
		)
		var map_pos := center + normalized * (minimap_size / 2) * 0.9
		map_pos = map_pos.clamp(Vector2(dot_size, dot_size), minimap_size - Vector2(dot_size, dot_size))
		var color = get_enemy_color(enemy)
		if enemy.isZombie:
			color = Color(0.0, 0.61, 0.068, 1.0)
		draw_circle(map_pos, dot_size,color)

func get_enemy_color(enemy) -> Color:
	if "enemyID" not in enemy:
		return enemy_color
	match enemy.enemyID:
		Enemy.EnemyID.HEXAGON_MOTHERSHIP: return Color(1.0, 1.0, 0.2, 1.0)
		Enemy.EnemyID.SHOOTY_DIAMOND: return Color(1.0, 0.539, 0.861, 1.0)
		Enemy.EnemyID.SPEEDY_TRIANGLE: return Color(1.0, 0.219, 0.254, 1.0)
		Enemy.EnemyID.BASIC_SQUARE: return Color(1.0, 1.0, 1.0, 1.0)
		_: return Color(1.0, 1.0, 1.0, 1.0)
