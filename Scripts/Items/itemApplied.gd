extends Item

@onready var amountLabel = $amountLabel

func _ready() -> void:
	#buildItem("Copper Gem")
	#amount = 100
	#CityManager.addItem(self)
	pass

func buildItem(itemNamePass):
	match itemNamePass:

		"Copper Gem":
			itemName = "Copper Gem"
			rarity = Rarity.COMMON
			actualItem = theItem.COPPER_GEM
			type = Type.GEM
			moneyValue = CityManager.getItemValue(itemName)
			texture = load("res://Textures/Citizens/Gems/copperGem.png")
		"Quartz Gem":
			itemName = "Quartz Gem"
			rarity = Rarity.RARE
			actualItem = theItem.QUARTZ_GEM
			type = Type.GEM
			moneyValue = CityManager.getItemValue(itemName)
			texture = load("res://Textures/Citizens/Gems/Quartz.png")
		"Amethyst Gem":
			itemName = "Amethyst Gem"
			rarity = Rarity.SUPER_RARE
			actualItem = theItem.AMETHYST_GEM
			type = Type.GEM
			moneyValue = CityManager.getItemValue(itemName)
			texture = load("res://Textures/Citizens/Gems/Amethyst Gem.png")
		"Diamond Gem":
			itemName = "Diamond Gem"
			rarity = Rarity.LEGENDARY
			actualItem = theItem.DIAMOND_GEM
			type = Type.GEM
			moneyValue = CityManager.getItemValue(itemName)
			texture = load("res://Textures/Citizens/Gems/Diamond Gem.png")


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			itemPopup = load("res://Item Scenes/Item Popup.tscn")
			itemPopup = itemPopup.instantiate()
			itemPopup.set_position(get_global_mouse_position())
			itemPopup.position.y -= 330
			itemPopup.position.x -= 430
			add_child(itemPopup)
			itemPopup.setItem(itemName)
