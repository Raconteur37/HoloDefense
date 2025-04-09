extends Area2D

var citizen

func _ready() -> void:
	citizen = $".."

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not citizen.selected and citizen.currentState != "Delivering":
				CityManager.citizensSelected.append(citizen)
				citizen.selected = true
			else:
				CityManager.citizensSelected.erase(citizen)
				citizen.selected = false
