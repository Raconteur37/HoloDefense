extends Area2D

var citizen

func _ready() -> void:
	citizen = $".."

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not citizen.selected and citizen.currentState != "Delivering":
				citizen.selected = true
			else:
				citizen.selected = false
