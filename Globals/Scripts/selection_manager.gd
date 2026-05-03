extends Node2D

var cityCanvas

var isDragging = false
var dragStart = Vector2.ZERO
var dragEnd = Vector2.ZERO

@export var boxColor: Color = Color(0.0, 0.782, 0.789, 0.3) 
@export var lineColor: Color = Color(0.0, 0.188, 0.984, 0.702)

func _ready():
	cityCanvas = $".."
	z_index = 100

func _input(event):
	if event is InputEventMouseButton && cityCanvas.visible:
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
					dragEnd = get_global_mouse_position()
					selectAllInBox()
				
				queue_redraw()


		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if not CityManager.citizensSelected.is_empty():
				giveMoveOrder(get_global_mouse_position())

	if event is InputEventMouseMotion and isDragging:
		dragEnd = get_global_mouse_position()
		queue_redraw()

func _clear_current_selection():
	var toDeselect = CityManager.citizensSelected.duplicate()
	CityManager.citizensSelected.clear()
	for cit in toDeselect:
		if is_instance_valid(cit):
			cit.deselect()

func singleSelect(clickPos: Vector2):
	if not Input.is_key_pressed(KEY_SHIFT):
		_clear_current_selection()

	var allCitizens = get_tree().get_nodes_in_group("Citizen")
	for citizen in allCitizens:
		if citizen is Citizen:
			if citizen.global_position.distance_to(clickPos) < 30:
				citizen.selected = true
				if not CityManager.citizensSelected.has(citizen):
					CityManager.citizensSelected.append(citizen)
				return 

func selectAllInBox():
	var rect = Rect2(dragStart, dragEnd - dragStart).abs()
	
	if not Input.is_key_pressed(KEY_SHIFT):
		_clear_current_selection()

	var allCitizens = get_tree().get_nodes_in_group("Citizen")
	for citizen in allCitizens:
		if citizen is Citizen:
			if rect.has_point(citizen.global_position):
				citizen.selected = true
				if not CityManager.citizensSelected.has(citizen):
					CityManager.citizensSelected.append(citizen)

func giveMoveOrder(destination: Vector2):
	var count = CityManager.citizensSelected.size()
	var spread = 35.0
	for i in range(count):
		var cit : Citizen = CityManager.citizensSelected[i]
		if is_instance_valid(cit):
			var offset = Vector2.from_angle(randf() * TAU) * (randf() * spread * sqrt(count))
			cit.moveToMouse(destination + offset)
			cit.currentState = Citizen.State.IDLE
			cit.currentJob = Citizen.Job.NONE
			cit.hasJob = false

func _draw():
	if isDragging:
		var rect = Rect2(dragStart, dragEnd - dragStart).abs()
		draw_rect(rect, boxColor, true)
		draw_rect(rect, lineColor, false, 2.0)
