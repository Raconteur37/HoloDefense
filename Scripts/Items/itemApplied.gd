extends Item

@onready var amountLabel = $amountLabel

func buildItem(itemNamePass):
	match itemNamePass:

		"Copper Gem":
			itemName = "Copper Gem"
			rarity = Rarity.COMMON
			actualItem = theItem.COPPER_GEM
			type = Type.GEM
			moneyValue = CityManager.getItemValue(itemName)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			itemPopup = load("res://Item Scenes/Item Popup.tscn")
			itemPopup = itemPopup.instantiate()
			itemPopup.set_position(get_global_mouse_position())
			itemPopup.position.y -= 330
			add_child(itemPopup)
			itemPopup.setItem(itemName)
