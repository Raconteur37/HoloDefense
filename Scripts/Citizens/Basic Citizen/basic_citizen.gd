extends Node2D

var selected
var moveLine = null

@onready var moveLineScene = preload("res://Particle Scenes/Citizens/Movement Line/Citizen Movement Line.tscn")

func _ready() -> void:
	selected = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if selected:
				var mouse_pos = get_viewport().get_mouse_position()
				moveToMouse(mouse_pos)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if selected:
				selected = false
				moveLine.queue_free()


func moveToMouse(mousePos):
	
	if moveLine != null:
		moveLine.queue_free()
	
	var moveLineCurrent = moveLineScene.instantiate()
	
	moveLineCurrent.global_position = to_local(global_position)

	# Set the positions
	var start_position = Vector2(0,0)
	var end_position = to_local(mousePos)
	var points = [start_position,end_position]

	moveLineCurrent.points = points

	moveLine = moveLineCurrent

	add_child(moveLineCurrent)
