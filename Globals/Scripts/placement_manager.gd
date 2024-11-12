extends Node

var tileMap

var occupied_cells = {}

var cell_size = Vector2(32, 32)  
var grid_origin = Vector2(0, 0)

var turretSelected : bool = false

var selectedTurret

func _input(event: InputEvent) -> void:
	
	if event is InputEventKey and event.is_pressed():
		
		if turretSelected:
			selectedTurret.queue_free()
			turretSelected = false
		
		match event.keycode:
			KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
				if Input.is_key_pressed(KEY_SHIFT):
					if GameManager.getUpgradeTokens() > 0:
						GameManager.removeUpgradeToken()
						var number_pressed = event.keycode - KEY_0
						GameManager.upgradeTurret(number_pressed)
				else:
					selectedTurret = GameManager.getTurret(event.keycode - KEY_0).instantiate()
					turretSelected = true
					get_tree().root.get_node("/root/Game").find_child("CanvasLayer").add_child(selectedTurret)
					
	if event.is_action_pressed("turret_selected_cancel") and turretSelected:
		selectedTurret.queue_free()
		turretSelected = false
		
	if event.is_action_pressed("turret_selected_place"):
		if turretSelected:
			if GameManager.getCurrentMoney() >= selectedTurret.getCost():
				if place_item_in_cell(selectedTurret.position):
					selectedTurret.isPlaced = true
					selectedTurret.hideRange()
					turretSelected = false
					GameManager.addTurretToDict(selectedTurret)
					GameManager.subtractMoney(selectedTurret.getCost())
					selectedTurret = null
				else:
					print("Cannot place turret there!")
					selectedTurret.queue_free()
					turretSelected = false
					selectedTurret = null
			else:
				print("Not enough money!")
				selectedTurret.queue_free()
				turretSelected = false
				selectedTurret = null
		else:
			if not is_cell_occupied(get_tree().root.get_node("/root/Game").get_global_mouse_position()):
				GameManager.closeAllMenus()
			#print(get_snapped_position(get_tree().root.get_node("/root/Game").get_global_mouse_position()))
			#if occupied_cells.has(get_snapped_position(get_tree().root.get_node("/root/Game").get_global_mouse_position())):
				#var turret = occupied_cells.get(get_snapped_position(get_tree().root.get_node("/root/Game").get_global_mouse_position()))
				#turret.openSelectedMenu()
				
func is_cell_occupied(position: Vector2):
	return occupied_cells.has(position)

func place_item_in_cell(position: Vector2):
	if not is_cell_occupied(position):
		selectedTurret.position = position
		occupied_cells[get_snapped_position(position)] = selectedTurret  # Mark this cell as occupied]
		return true
	else:
		# Handle overlap case (e.g., prevent placement or show a warning)
		return false

func get_selected_cell(mouse_position: Vector2):
	# Calculate the mouse position relative to the grid origin
	var relative_position = mouse_position - grid_origin
	var snapped_x = int(relative_position.x / cell_size.x)
	
	var snapped_y = int(relative_position.y / cell_size.y)
	
	return Vector2(snapped_x, snapped_y)

func _process(delta: float) -> void:
	
	if turretSelected:
		if not selectedTurret.isPlaced:
			var mousePosition = get_tree().root.get_node("/root/Game").get_global_mouse_position()

			selectedTurret.global_position = get_snapped_position(mousePosition)
			#global_position = world_pos
	
func get_snapped_position(mouse_position: Vector2):
	# Calculate the grid cell position
	var relative_position = mouse_position - grid_origin
	var snapped_x = int(relative_position.x / cell_size.x)
	var snapped_y = int(relative_position.y / cell_size.y)

	# Calculate the snapped position (center of the cell)
	var snapped_position = grid_origin + Vector2(snapped_x, snapped_y) * cell_size

	# Calculate the position that centers the sprite within the cell
	var centered_position = snapped_position + (cell_size - Vector2(32,32)) / 2
	return centered_position


func get_grid_world_position(selected_cell: Vector2):
	return grid_origin + selected_cell * cell_size
	
func draw_range_cirle(line2d,attackRange):
	
	line2d.clear_points()
	
	for i in range(32):
		var angle = (i / float(32)) * TAU
		var point = Vector2(cos(angle), sin(angle)) * attackRange
		line2d.add_point(point)
		
	line2d.add_point(Vector2(cos(0), sin(0)) * attackRange)
	return line2d

func setCurrentTileMap(map):
	tileMap = map

func getCurrentTileMap():
	return tileMap
