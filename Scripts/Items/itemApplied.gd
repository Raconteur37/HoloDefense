extends Item

@onready var amountLabel = $amountLabel
@onready var itemPopup = $ItemPopup

func _ready() -> void:
	#buildItem(Item.theItem.COPPER_GEM)
	#amount = 100
	#itemPopup.item = self
	#CityManager.addItem(Item.theItem.COPPER_GEM)
	itemPopup.item = self
	itemPopup.buildItemDisplay()
	CityManager.storageChanged.connect(updateUI)
	pass

func setAmount(amount):
	self.amount = amount

func updateUI():
	amountLabel.text = "x" + str(amount)

func buildItem(item):
	match item:

		Item.theItem.COPPER_GEM:
			itemName = "Copper Gem"
			rarity = Rarity.COMMON
			actualItem = theItem.COPPER_GEM
			type = Type.GEM
			moneyValue = CityManager.getItemValue(itemName)
			texture = load("res://Textures/Citizens/Gems/copperGem.png")
		Item.theItem.QUARTZ_GEM:
			itemName = "Quartz Gem"
			rarity = Rarity.RARE
			actualItem = theItem.QUARTZ_GEM
			type = Type.GEM
			moneyValue = CityManager.getItemValue(itemName)
			texture = load("res://Textures/Citizens/Gems/Quartz.png")
		Item.theItem.AMETHYST_GEM:
			itemName = "Amethyst Gem"
			rarity = Rarity.SUPER_RARE
			actualItem = theItem.AMETHYST_GEM
			type = Type.GEM
			moneyValue = CityManager.getItemValue(itemName)
			texture = load("res://Textures/Citizens/Gems/Amethyst Gem.png")
		Item.theItem.DIAMOND_GEM:
			itemName = "Diamond Gem"
			rarity = Rarity.LEGENDARY
			actualItem = theItem.DIAMOND_GEM
			type = Type.GEM
			moneyValue = CityManager.getItemValue(itemName)
			texture = load("res://Textures/Citizens/Gems/Diamond Gem.png")


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			itemPopup.buildItemDisplay()
			itemPopup.set_position(get_global_mouse_position())
			itemPopup.position.y -= 330
			itemPopup.position.x -= 430
			itemPopup.show()
