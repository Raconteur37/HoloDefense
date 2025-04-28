extends Camera2D

var zoom_min := 0.5
var zoom_max := 4.0
var zoom_speed := 0.1

var world_rect := Rect2(Vector2.ZERO, Vector2(1920, 1080)) # example: 3000x2000 world

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_toward_mouse(event.position, 1.0 - zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_toward_center(1.0 + zoom_speed)

func zoom_toward_mouse(mouse_pos: Vector2, zoom_factor: float):
	var before = to_global(mouse_pos)
	zoom *= zoom_factor
	zoom.x = clamp(zoom.x, zoom_min, zoom_max)
	zoom.y = clamp(zoom.y, zoom_min, zoom_max)
	var after = to_global(mouse_pos)
	global_position += before - after
	clamp_to_bounds()

func zoom_toward_center(zoom_factor: float):
	var viewport_center = get_viewport_rect().size * 0.5
	var center_world = to_global(viewport_center)
	var before = center_world
	zoom *= zoom_factor
	zoom.x = clamp(zoom.x, zoom_min, zoom_max)
	zoom.y = clamp(zoom.y, zoom_min, zoom_max)
	var after = center_world
	global_position += before - after
	clamp_to_bounds()

func clamp_to_bounds():
	var viewport_size = get_viewport_rect().size
	var half_screen = viewport_size * 0.5 * zoom

	var min_pos = world_rect.position + half_screen
	var max_pos = world_rect.position + world_rect.size - half_screen

	global_position.x = clamp(global_position.x, min_pos.x, max_pos.x)
	global_position.y = clamp(global_position.y, min_pos.y, max_pos.y)
