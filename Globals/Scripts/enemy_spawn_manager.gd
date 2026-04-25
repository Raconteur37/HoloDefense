extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func summonEnemy():
	pass

func get_random_offscreen_position() -> Vector2:
	var view_rect = get_tree().current_scene.get_viewport_rect()
	var margin = 50.0 
	
	var side = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match side:
		# Top
		0: 
			spawn_pos.x = randf_range(0, view_rect.size.x)
			spawn_pos.y = -margin
		1: # Bottom
			spawn_pos.x = randf_range(0, view_rect.size.x)
			spawn_pos.y = view_rect.size.y + margin
		2: # Left
			spawn_pos.x = -margin
			spawn_pos.y = randf_range(0, view_rect.size.y)
		3: # Right
			spawn_pos.x = view_rect.size.x + margin
			spawn_pos.y = randf_range(0, view_rect.size.y)
			
	return spawn_pos
