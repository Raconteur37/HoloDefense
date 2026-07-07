extends Item

@onready var amountLabel = $amountLabel
@onready var itemPopup = $ItemPopup

func _ready() -> void:
	#buildItem(Item.theItem.UNSEEN_SCRAP)
	#amount = 100
	#itemPopup.item = self
	#CityManager.addItem(Item.theItem.UNSEEN_SCRAP)
	
	itemPopup.item = self
	itemPopup.buildItemDisplay()
	CityManager.storageChanged.connect(update)

func setAmount(amount):
	self.amount = amount

func update():
	
	if type == Type.MATERIAL:
		moneyValue = CityManager.itemMoneyValueDict.get(actualItem)
		scrapValue = CityManager.itemScrapValueDict.get(actualItem)
	if type == Type.GEM:
		moneyValue = CityManager.itemMoneyValueDict.get(actualItem)
		energyValue = CityManager.itemEnergyValueDict.get(actualItem)
	
	amountLabel.text = "x" + str(amount)
	if amount <= 0:
		queue_free()

func buildItem(item):
	match item:

		Item.theItem.COPPER_GEM:
			itemName = "Copper Gem"
			rarity = Rarity.COMMON
			actualItem = theItem.COPPER_GEM
			type = Type.GEM
			moneyValue = CityManager.getMoneyItemValue(actualItem)
			energyValue = CityManager.getEnergyItemValue(actualItem)
			texture = load("res://Textures/Citizens/Gems/small_gems20.png")
			scale = Vector2(0.6,0.6)
		Item.theItem.QUARTZ_GEM:
			itemName = "Quartz Gem"
			rarity = Rarity.RARE
			actualItem = theItem.QUARTZ_GEM
			type = Type.GEM
			moneyValue = CityManager.getMoneyItemValue(actualItem)
			energyValue = CityManager.getEnergyItemValue(actualItem)
			texture = load("res://Textures/Citizens/Gems/small_gems21.png")
		Item.theItem.AMETHYST_GEM:
			itemName = "Amethyst Gem"
			rarity = Rarity.SUPER_RARE
			actualItem = theItem.AMETHYST_GEM
			type = Type.GEM
			moneyValue = CityManager.getMoneyItemValue(actualItem)
			energyValue = CityManager.getEnergyItemValue(actualItem)
			texture = load("res://Textures/Citizens/Gems/small_gems22.png")
		Item.theItem.DIAMOND_GEM:
			itemName = "Diamond Gem"
			rarity = Rarity.LEGENDARY
			actualItem = theItem.DIAMOND_GEM
			type = Type.GEM
			moneyValue = CityManager.getMoneyItemValue(actualItem)
			energyValue = CityManager.getEnergyItemValue(actualItem)
			texture = load("res://Textures/Citizens/Gems/small_gems23.png")
			scale = Vector2(0.9,0.9)
		Item.theItem.GALACTITE_GEM:
			itemName = "Galactite"
			rarity = Rarity.UNSEEN
			actualItem = theItem.GALACTITE_GEM
			type = Type.GEM
			moneyValue = CityManager.getMoneyItemValue(actualItem)
			energyValue = CityManager.getEnergyItemValue(actualItem)
			texture = load("res://Textures/Citizens/Gems/small_gems24.png")
		Item.theItem.COMMON_SCRAP:
			itemName = "Basic Scrap"
			rarity = Rarity.COMMON
			actualItem = theItem.COMMON_SCRAP
			type = Type.MATERIAL
			moneyValue = CityManager.getMoneyItemValue(actualItem)
			scrapValue = CityManager.getScrapItemValue(actualItem)
			texture = load("res://Textures/Citizens/Scrap/Common Scrap.png")
		Item.theItem.RARE_SCRAP:
			itemName = "Rare Scrap"
			rarity = Rarity.RARE
			actualItem = theItem.RARE_SCRAP
			type = Type.MATERIAL
			moneyValue = CityManager.getMoneyItemValue(actualItem)
			scrapValue = CityManager.getScrapItemValue(actualItem)
			texture = load("res://Textures/Citizens/Scrap/Rare Scrap.png")
		Item.theItem.SUPER_RARE_SCRAP:
			itemName = "Super Rare Scrap"
			rarity = Rarity.SUPER_RARE
			actualItem = theItem.SUPER_RARE_SCRAP
			type = Type.MATERIAL
			moneyValue = CityManager.getMoneyItemValue(actualItem)
			scrapValue = CityManager.getScrapItemValue(actualItem)
			texture = load("res://Textures/Citizens/Scrap/Super Rare Scrap.png")
		Item.theItem.LEGENDARY_SCRAP:
			itemName = "Legendary Scrap"
			rarity = Rarity.LEGENDARY
			actualItem = theItem.LEGENDARY_SCRAP
			type = Type.MATERIAL
			moneyValue = CityManager.getMoneyItemValue(actualItem)
			scrapValue = CityManager.getScrapItemValue(actualItem)
			texture = load("res://Textures/Citizens/Scrap/Legendary Scrap.png")
		Item.theItem.UNSEEN_SCRAP:
			itemName = "Unseen Scrap"
			rarity = Rarity.UNSEEN
			actualItem = theItem.UNSEEN_SCRAP
			type = Type.MATERIAL
			moneyValue = CityManager.getMoneyItemValue(actualItem)
			scrapValue = CityManager.getScrapItemValue(actualItem)
			texture = load("res://Textures/Citizens/Scrap/Unseen Scrap.png")


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			itemPopup.buildItemDisplay()
			itemPopup.set_position(get_global_mouse_position())
			itemPopup.position.y -= 330
			#itemPopup.position.x += 430
			itemPopup.show()
