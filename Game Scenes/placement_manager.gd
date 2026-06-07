extends Node2D

@export var tilemap: TileMapLayer
@export var tile_size: int = 32
@export var preview_radius: int = 2
@export var show_range_preview: bool = true

@export var valid_color:       Color = Color(0.2, 1.0, 0.4,  0.25)
@export var invalid_color:     Color = Color(1.0, 0.2, 0.2,  0.25)
@export var grid_line_color:   Color = Color(1.0, 1.0, 1.0,  0.12)
@export var center_color:      Color = Color(0.3, 0.9, 1.0,  0.45)
@export var range_ring_color:  Color = Color(0.2, 0.8, 1.0,  0.18)
@export var range_ring_border: Color = Color(0.2, 0.8, 1.0,  0.55)

var sell_shader: ShaderMaterial = load("res://Shaders/fabricate.tres")

var _placing: bool = false
var _current_id: Turret.TurretID
var _ghost: Node2D = null
var _ghost_sprite: Sprite2D = null
var _occupied: Dictionary = {}
var _hovered_cell: Vector2i = Vector2i(-9999, -9999)
var _range_radius: float = 0.0

var _time: float = 0.0
var _cell_alpha: Dictionary = {}
var _prev_cells: Array = []

var _sell_cell: Vector2i = Vector2i(-9999, -9999)
var _sell_progress: float = 0.0
var _sell_hold_duration: float = 1.0
var _right_held: bool = false
var _sell_turret_node: Node = null
var _sell_sprite: Sprite2D = null
var _sell_sprite_original_material: Material = null

signal turret_placed(cell: Vector2i, turret: Node)

func begin_placement(id: Turret.TurretID) -> void:
	if _placing and _current_id == id:
		cancel_placement()
		return
	if GameManager.getTurretAmount(id) <= 0:
		if _placing:
			cancel_placement()
		return

	_placing = false
	_hovered_cell = Vector2i(-9999, -9999)
	_range_radius = 0.0
	_cell_alpha.clear()
	_prev_cells.clear()
	if _ghost:
		_ghost.free()
		_ghost = null
	_ghost_sprite = null

	_current_id = id
	_placing = true
	_build_ghost(id)
	_force_update_ghost(get_global_mouse_position())


func cancel_placement() -> void:
	_placing = false
	_hovered_cell = Vector2i(-9999, -9999)
	if _ghost:
		_ghost.queue_free()
		_ghost = null
	_ghost_sprite = null
	_range_radius = 0.0
	_cell_alpha.clear()
	_prev_cells.clear()
	queue_redraw()


func is_placing() -> bool:
	return _placing


func free_cell(world_pos: Vector2) -> void:
	var cell := _world_to_cell(world_pos)
	_occupied.erase(cell)


func _build_ghost(id: Turret.TurretID) -> void:
	_ghost = Node2D.new()
	_ghost.z_index = 20
	add_child(_ghost)

	_ghost_sprite = Sprite2D.new()
	_ghost_sprite.texture = TurretManager.getTurretTexture(id)
	_ghost_sprite.modulate = Color(0.5, 1.0, 0.5, 0.6)
	_ghost_sprite.visible = true
	_ghost.add_child(_ghost_sprite)

	_range_radius = 0.0
	if show_range_preview:
		_range_radius = TurretManager.getTurretStat(id, "range")


func _set_ghost_tint(valid: bool) -> void:
	if _ghost_sprite:
		_ghost_sprite.modulate = Color(0.5, 1.0, 0.5, 0.6) if valid \
								 else Color(1.0, 0.4, 0.4, 0.6)

# ─── Sell shader helpers ──────────────────────────────────────────────────────

func _apply_sell_shader() -> void:
	if not is_instance_valid(_sell_turret_node):
		return
	for node_name in ["TurretBottom", "TurretTop"]:
		var sprite: CanvasItem = _sell_turret_node.get_node_or_null(node_name)
		if sprite:
			sprite.set_meta("original_material", sprite.material)
			var mat: ShaderMaterial = sell_shader.duplicate()
			mat.set_shader_parameter("progress", 1.0)
			sprite.material = mat



func _remove_sell_shader() -> void:
	if is_instance_valid(_sell_turret_node):
		for node_name in ["TurretBottom", "TurretTop"]:
			var sprite: CanvasItem = _sell_turret_node.get_node_or_null(node_name)
			if sprite and sprite.has_meta("original_material"):
				sprite.material = sprite.get_meta("original_material")
				sprite.remove_meta("original_material")
	_sell_sprite = null
	_sell_sprite_original_material = null


func _set_sell_shader_progress(p: float) -> void:
	if not is_instance_valid(_sell_turret_node):
		return
	for node_name in ["TurretBottom", "TurretTop"]:
		var sprite: CanvasItem = _sell_turret_node.get_node_or_null(node_name)
		if sprite and sprite.material:
			sprite.material.set_shader_parameter("progress", p)

# ─── Process ──────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if _right_held and _sell_cell != Vector2i(-9999, -9999):
		_sell_progress = min(_sell_progress + delta / _sell_hold_duration, 1.0)
		# Drive shader: 1.0 → 0.0 as progress goes 0.0 → 1.0
		_set_sell_shader_progress(1.0 - _sell_progress)
		if _sell_progress >= 1.0:
			_try_sell(_sell_cell)
		return

	if not _placing:
		return
	_time += delta
	var current_cells := _get_preview_cells()
	for c in current_cells:
		if not _cell_alpha.has(c):
			_cell_alpha[c] = 0.0
	var fade_speed := 8.0
	for c in _cell_alpha.keys():
		if c in current_cells:
			_cell_alpha[c] = min(_cell_alpha[c] + delta * fade_speed, 1.0)
		else:
			_cell_alpha[c] = max(_cell_alpha[c] - delta * fade_speed, 0.0)
			if _cell_alpha[c] <= 0.0:
				_cell_alpha.erase(c)
	_prev_cells = current_cells
	queue_redraw()


func _get_preview_cells() -> Array:
	if _hovered_cell == Vector2i(-9999, -9999):
		return []
	var cells: Array = []
	for dx in range(-preview_radius, preview_radius + 1):
		for dy in range(-preview_radius, preview_radius + 1):
			cells.append(Vector2i(_hovered_cell.x + dx, _hovered_cell.y + dy))
	return cells

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		
		if event.keycode == KEY_ESCAPE and _placing:
			cancel_placement()
			return
		if event.keycode == KEY_SPACE and _placing:
			cancel_placement()
			return
		var hotbar_map := {
			KEY_1: 0, KEY_2: 1, KEY_3: 2, KEY_4: 3, KEY_5: 4,
			KEY_6: 5, KEY_7: 6, KEY_8: 7, KEY_9: 8, KEY_0: 9
		}
		if hotbar_map.has(event.keycode):
			_try_hotbar_select(hotbar_map[event.keycode])
			return
		if event.keycode == KEY_ESCAPE and _placing:
			cancel_placement()
			return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_on_right_pressed(get_global_mouse_position())
			else:
				_on_right_released()
			return

	if not _placing:
		return

	if event is InputEventMouseMotion:
		_update_ghost(get_global_mouse_position())
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_place(get_global_mouse_position())


func _try_hotbar_select(idx: int) -> void:
	var available: Array = GameManager.turretStorage.keys()
	if idx >= available.size():
		if _placing:
			cancel_placement()
		return
	var id: Turret.TurretID = available[idx]
	begin_placement(id)

func _on_right_pressed(world_pos: Vector2) -> void:
	var cell := _world_to_cell(world_pos)
	if _occupied.has(cell):
		var holder := get_tree().current_scene.find_child("TurretNodeHolder")
		if holder:
			var cell_world := _cell_to_world(cell)
			for child in holder.get_children():
				if child.global_position.distance_to(cell_world) < tile_size * 0.5:
					_sell_turret_node = child
					break
		if _sell_turret_node == null:
			return
		_sell_cell = cell
		_sell_progress = 0.0
		_right_held = true
		_apply_sell_shader()
		queue_redraw()
	else:
		if _placing:
			cancel_placement()


func _on_right_released() -> void:
	if _right_held:
		# Cancelled mid-hold — restore shader and reset
		_remove_sell_shader()
		_right_held = false
		_sell_cell = Vector2i(-9999, -9999)
		_sell_progress = 0.0
		_sell_turret_node = null
		queue_redraw()


func _try_sell(cell: Vector2i) -> void:
	if not _occupied.has(cell):
		return
	var world_pos := _cell_to_world(cell)
	var holder := get_tree().current_scene.find_child("TurretNodeHolder")
	if holder:
		for child in holder.get_children():
			if child.global_position.distance_to(world_pos) < tile_size * 0.5:
				#print(round(child.price * 0.5))
				#print(child.price)
				CityManager.currentScrap += round(child.price * 0.5)
				GameManager.removeTurretFromGame(child)
				child.queue_free()
				break
	# Shader node is gone with the turret, just clear refs
	_sell_sprite = null
	_sell_sprite_original_material = null
	free_cell(world_pos)
	_sell_cell = Vector2i(-9999, -9999)
	_sell_progress = 0.0
	_right_held = false
	_sell_turret_node = null
	queue_redraw()


func _world_to_cell(world_pos: Vector2) -> Vector2i:
	if tilemap:
		return tilemap.local_to_map(tilemap.to_local(world_pos))
	return Vector2i(int(floor(world_pos.x / tile_size)),
					int(floor(world_pos.y / tile_size)))


func _cell_to_world(cell: Vector2i) -> Vector2:
	if tilemap:
		return tilemap.to_global(tilemap.map_to_local(cell))
	return Vector2(cell.x * tile_size + tile_size * 0.5,
				   cell.y * tile_size + tile_size * 0.5)


func _is_cell_valid(cell: Vector2i) -> bool:
	if _occupied.has(cell):
		return false
	if tilemap and tilemap.get_cell_tile_data(cell) == null:
		return false
	return true


func _force_update_ghost(world_pos: Vector2) -> void:
	var cell := _world_to_cell(world_pos)
	_hovered_cell = cell
	var valid := _is_cell_valid(cell)
	if _ghost:
		_ghost.global_position = _cell_to_world(cell)
	_set_ghost_tint(valid)
	if not _cell_alpha.has(cell):
		_cell_alpha[cell] = 1.0
	queue_redraw()


func _update_ghost(world_pos: Vector2) -> void:
	var cell := _world_to_cell(world_pos)
	if cell == _hovered_cell:
		return
	_hovered_cell = cell
	var valid := _is_cell_valid(cell)
	if _ghost:
		_ghost.global_position = _cell_to_world(cell)
		_ghost.visible = valid
	_set_ghost_tint(valid)
	queue_redraw()


func _try_place(world_pos: Vector2) -> void:
	var cell := _world_to_cell(world_pos)
	if not _is_cell_valid(cell):
		return
	var amount: int = GameManager.getTurretAmount(_current_id)
	if amount <= 0:
		cancel_placement()
		return
	var packed = TurretManager.loadTurretByID(_current_id)
	if packed == null:
		push_error("TurretPlacementManager: loadTurretByID returned null for id %s" % _current_id)
		return
	var turret: Node = packed.instantiate()
	var parent: Node = get_tree().current_scene.find_child("TurretNodeHolder")
	parent.add_child(turret)
	turret.global_position = _cell_to_world(cell)
	var range_indicator = turret.get_node_or_null("RangeArea/RangeIndicator")
	if range_indicator:
		range_indicator.visible = false
	_occupied[cell] = true
	GameManager.removeTurretFromStorage(_current_id, 1)
	turret_placed.emit(cell, turret)
	GameManager.addTurretToDict(turret)
	StatManager.addStat(turret.turretID,"placed",1)
	if GameManager.getTurretAmount(_current_id) <= 0:
		cancel_placement()

# ─── Draw ─────────────────────────────────────────────────────────────────────

func _draw() -> void:
	if not _placing or _hovered_cell == Vector2i(-9999, -9999):
		return

	var cell  := _hovered_cell
	var valid := _is_cell_valid(cell)
	var half  := tile_size * 0.5

	# Range ring
	if show_range_preview and _range_radius > 0.0:
		var center := to_local(_cell_to_world(cell))
		var breathe := sin(_time * 2.5) * 2.5
		var r := _range_radius + breathe
		var points: PackedVector2Array = []
		for i in range(65):
			var angle := TAU * i / 64.0
			points.append(center + Vector2(cos(angle), sin(angle)) * r)
		var ring_alpha := 0.45 + sin(_time * 2.5) * 0.15
		draw_polyline(points, Color(range_ring_border.r, range_ring_border.g,
								   range_ring_border.b, ring_alpha), 1.5, true)

	# Grid cells
	for dx in range(-preview_radius, preview_radius + 1):
		for dy in range(-preview_radius, preview_radius + 1):
			var nc    := Vector2i(cell.x + dx, cell.y + dy)
			var alpha: float = _cell_alpha.get(nc, 0.0)
			if alpha <= 0.0:
				continue
			var top_left := to_local(_cell_to_world(nc) - Vector2(half, half))
			var rect     := Rect2(top_left, Vector2(tile_size, tile_size))
			var dist     := sqrt(float(dx * dx + dy * dy))
			var wave     := sin(_time * 4.0 - dist * 1.2) * 0.5 + 0.5
			var is_center := dx == 0 and dy == 0

			var fill: Color
			if is_center:
				var pulse := 0.6 + wave * 0.4
				fill = center_color if valid else invalid_color
				fill.a = fill.a * pulse * alpha
			else:
				fill = valid_color if _is_cell_valid(nc) else Color(0, 0, 0, 0)
				fill.a = fill.a * alpha
			draw_rect(rect, fill)

			var line_alpha := (0.08 + wave * 0.1) * alpha
			draw_rect(rect, Color(grid_line_color.r, grid_line_color.g,
								  grid_line_color.b, line_alpha), false, 1.0)

	# Center border
	var center_alpha: float = _cell_alpha.get(cell, 0.0)
	if center_alpha > 0.0:
		var pulse_border := 0.7 + sin(_time * 5.0) * 0.3
		var border_base  := Color(0.3, 1.0, 0.5, 0.9) if valid else Color(1.0, 0.3, 0.3, 0.9)
		draw_rect(Rect2(to_local(_cell_to_world(cell) - Vector2(half, half)),
					Vector2(tile_size, tile_size)),
				Color(border_base.r, border_base.g, border_base.b,
					  border_base.a * pulse_border * center_alpha),
				false, 2.0)


func reset():
	_occupied.clear()
