extends Area2D

var turret

func _ready() -> void:
	turret = $".."

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("turret_selected_place"):
			GameManager.closeAllMenus()
			turret.openSelectedMenu()
			print("clicked me")
