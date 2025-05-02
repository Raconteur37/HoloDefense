extends TextureRect

var itemName = "Copper Gem"

var itemPopup = null

var amount = 0

@onready var amountLabel = $Label


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			itemPopup = load("res://Item Scenes/Common Item Popup.tscn")
			itemPopup = itemPopup.instantiate()
			itemPopup.set_position(get_global_mouse_position())
			add_child(itemPopup)
