extends Control

var menu

var activeSlots = 1
var maxSlots = 10

func _ready() -> void:
	menu = $menuControl
	
	if menu.visible:
		menu.hide()

func _on_select_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			menu.show()
