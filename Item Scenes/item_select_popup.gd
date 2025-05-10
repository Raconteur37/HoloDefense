extends Popup

var item : Item

@onready var itemNameLabel = $"MainBackground/Item Name"

@onready var slider = $SellSliderBackground/HSlider

@onready var sellMenu = $SellSliderBackground
@onready var sellSliderButton = $SellSliderBackground/HBoxContainer/SellButton/SellLabel
@onready var sliderItemAmount = $SellSliderBackground/AmountLabel
@onready var sellAmountText = $SellSliderBackground/SellAmountText

@onready var itemAmountLabel = $MainBackground/AmountLabel
@onready var itemValueLabel = $MainBackground/ValueLabel
@onready var itemRarityLabel = $"MainBackground/Rarity Label"

@onready var itemImage = $MainBackground/ItemImage
@onready var mainBackground = $MainBackground


func setItem(itemName):

	item = CityManager.getStorageItem(itemName)

	setItemImage(item)
	itemNameLabel.text = item.itemName
	itemAmountLabel.text = "Amount: [color=gray]x" + str(item.amount) + "[/color]"
	itemValueLabel.text = "Value: [color=gold]$" + str(int(item.moneyValue * item.amount)) + "[/color]"
	if item.rarity == Item.Rarity.COMMON:
		itemRarityLabel.text = "Common"
	if item.rarity == Item.Rarity.RARE:
		itemRarityLabel.text = "Rare"
	if item.rarity == Item.Rarity.SUPER_RARE:
		itemRarityLabel.text = "Super Rare"
	if item.rarity == Item.Rarity.LEGENDARY:
		itemRarityLabel.text = "Legendary"

func setItemImage(item):

	match item.actualItem:

		Item.theItem.COPPER_GEM:
			itemImage.texture = load("res://Textures/Citizens/Gems/copperGem.png")
			mainBackground.texture = load("res://Textures/UI/Item/Copper Gem UI.png")
		Item.theItem.QUARTZ_GEM:
			itemImage.texture = load("res://Textures/Citizens/Gems/Quartz.png")
			mainBackground.texture = load("res://Textures/UI/Item/Quartz Item Popup.png")
		Item.theItem.AMETHYST_GEM:
			itemImage.texture = load("res://Textures/Citizens/Gems/Amethyst Gem.png")
			mainBackground.texture = load("res://Textures/UI/Item/Amethyst Item Popup.png")
		Item.theItem.DIAMOND_GEM:
			itemImage.texture = load("res://Textures/Citizens/Gems/Diamond Gem.png")
			mainBackground.texture = load("res://Textures/UI/Item/Diamond Item UI.png")

func _on_popup_hide() -> void:
	queue_free()

func _on_selll_button_pressed() -> void:
	$SellSliderBackground/AmountLabel.text = "[color=gray]x" + str(item.amount) + "[/color]"
	slider.value = 0
	slider.max_value = item.amount
	sellMenu.show()

func _on_cancel_button_pressed() -> void:
	sellMenu.hide()

func _on_h_slider_value_changed(value: float) -> void:
	sliderItemAmount.text = "[color=white]x" + str(item.amount - slider.value) + "[/color]"
	sellAmountText.text = "[color=gold]$" + str(item.moneyValue * slider.value) + "[/color]"


func _on_sell_button_pressed() -> void:
	item = CityManager.sellItem(item,slider.value)
	itemAmountLabel.text = "Amount: [color=gray]x" + str(item.amount) + "[/color]"
	itemValueLabel.text = "Value: [color=gold]$" + str(int(item.moneyValue * item.amount)) + "[/color]"
	if item.amount <= 0:
		CityManager.removeItemFromStorage(item.itemName)
	sellMenu.hide()
