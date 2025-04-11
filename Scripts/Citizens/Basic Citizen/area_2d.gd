extends Area2D

var citizen

func _ready() -> void:
	citizen = $".."

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not citizen.selected:
				CityManager.citizensSelected.append(citizen)
				citizen.selected = true
				if CityManager.citizensSelected.size() == 1:
					citizen.openMenu()
			else:
				CityManager.citizensSelected.erase(citizen)
				citizen.selected = false
