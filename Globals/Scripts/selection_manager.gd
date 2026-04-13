extends Node2D

var isDragging = false
var dragStart = Vector2.ZERO
var dragEnd = Vector2.ZERO

@export var boxColor: Color = Color(0.0, 0.782, 0.789, 0.3) 
@export var lineColor: Color = Color(0.0, 0.188, 0.984, 0.702)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				isDragging = true
				dragStart = get_global_mouse_position()
				dragEnd = dragStart
			else:
				isDragging = false
				var dragDist = dragStart.distance_to(get_global_mouse_position())
				
				if dragDist < 5:
					singleSelect(get_global_mouse_position())
				else:
					# Important: ensure dragEnd is finalized on release
					dragEnd = get_global_mouse_position()
					selectAllInBox()
				queue_redraw()

	if event is InputEventMouseMotion and isDragging:
		dragEnd = get_global_mouse_position()
		queue_redraw() # This triggers the _draw() function mid-drag

func singleSelect(clickPos: Vector2):
	if not Input.is_key_pressed(KEY_SHIFT):
		for cit in CityManager.citizensSelected:
			cit.deselect()
		CityManager.citizensSelected.clear()

	var allCitizens = get_tree().get_nodes_in_group("Citizen")
	
	for citizen in allCitizens:
		if citizen is Citizen:
			if citizen.global_position.distance_to(clickPos) < 25:
				citizen.selected = true
				citizen.hoverBox.visible = true
				CityManager.citizensSelected.append(citizen)
				return 

func _draw():
	if isDragging:
		var rect = Rect2(dragStart, dragEnd - dragStart).abs()
		draw_rect(rect, boxColor, true)  
		draw_rect(rect, lineColor, false, 2.0) 
		
func selectAllInBox():

	var rect = Rect2(dragStart, dragEnd - dragStart).abs()
	
	if not Input.is_key_pressed(KEY_SHIFT):
		for cit in CityManager.citizensSelected:
			cit.deselect()
		CityManager.citizensSelected.clear()

	var allCitizens = get_tree().get_nodes_in_group("Citizen")
	
	for citizen in allCitizens:
		if citizen is Citizen:
			if rect.has_point(citizen.global_position):
				citizen.selected = true
				citizen.hoverBox.visible = true
				if not CityManager.citizensSelected.has(citizen):
					CityManager.citizensSelected.append(citizen)

func give_move_order(destination: Vector2):
	var selected_count = CityManager.citizensSelected.size()
	
	var spread_distance = 35.0 
	
	for i in range(selected_count):
		var citizen = CityManager.citizensSelected[i]
		if is_instance_valid(citizen):

			var angle = randf() * TAU # its 2 pi
			var distance = randf() * (spread_distance * sqrt(selected_count))
			
			var offset = Vector2(cos(angle), sin(angle)) * distance
			var final_pos = destination + offset
			
			citizen.moveToMouse(final_pos)
