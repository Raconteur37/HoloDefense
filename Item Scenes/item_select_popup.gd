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

@onready var convertMenu = $ConvertSliderBackground
@onready var convertAmountPlateText = $ConvertSliderBackground/AmountLabel
@onready var convertAmountText = $ConvertSliderBackground/ConvertAmountText
@onready var convertSlider = $ConvertSliderBackground/convertHSlider

@onready var gemButtonContainer = $MainBackground/HBoxContainer

@onready var scrapButtonContainer = $MainBackground/HBoxContainer2
@onready var scrapButtonSell = $"MainBackground/HBoxContainer2/Selll Button"
@onready var scarpButtonConvert = $MainBackground/HBoxContainer2/ConvertScrapButton

@onready var convertScrapBackground = $ConvertScrapbackground
@onready var scrapAmountText = $ConvertScrapbackground/ScrapAmountText
@onready var scrapSlider = $ConvertScrapbackground/scrapSlider
@onready var scrapAmountPlateLabel = $ConvertScrapbackground/ScrapAmountPlateLabel

func _ready() -> void:
	CityManager.storageChanged.connect(refresh)


func buildItemDisplay():

	setItemImage()
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
	if item.rarity == Item.Rarity.UNSEEN:
		itemRarityLabel.text = "Unseen"
	if item.type == item.Type.MATERIAL:
		scrapButtonContainer.show()
		gemButtonContainer.hide()
	if item.type == item.Type.GEM:
		scrapButtonContainer.hide()
		gemButtonContainer.show()

func setItemImage():

	match item.actualItem:

		Item.theItem.COPPER_GEM:
			itemImage.texture = load("res://Textures/Citizens/Gems/small_gems20.png")
			mainBackground.texture = load("res://Textures/UI/Item/Copper Gem UI.png")
		Item.theItem.QUARTZ_GEM:
			itemImage.texture = load("res://Textures/Citizens/Gems/small_gems21.png")
			mainBackground.texture = load("res://Textures/UI/Item/Quartz Item Popup.png")
		Item.theItem.AMETHYST_GEM:
			itemImage.texture = load("res://Textures/Citizens/Gems/small_gems22.png")
			mainBackground.texture = load("res://Textures/UI/Item/Amethyst Item Popup.png")
		Item.theItem.DIAMOND_GEM:
			itemImage.texture = load("res://Textures/Citizens/Gems/small_gems23.png")
			mainBackground.texture = load("res://Textures/UI/Item/Diamond Item UI.png")
		Item.theItem.GALACTITE_GEM:
			itemImage.texture = load("res://Textures/Citizens/Gems/small_gems24.png")
			mainBackground.texture = load("res://Textures/UI/Item/Copper Gem UI.png")
		Item.theItem.COMMON_SCRAP:
			itemImage.texture = load("res://Textures/Citizens/Scrap/Common Scrap.png")
			mainBackground.texture = load("res://Textures/UI/Item/Copper Gem UI.png")
		Item.theItem.RARE_SCRAP:
			itemImage.texture = load("res://Textures/Citizens/Scrap/Rare Scrap.png")
			mainBackground.texture = load("res://Textures/UI/Item/Copper Gem UI.png")
		Item.theItem.SUPER_RARE_SCRAP:
			itemImage.texture = load("res://Textures/Citizens/Scrap/Super Rare Scrap.png")
			mainBackground.texture = load("res://Textures/UI/Item/Copper Gem UI.png")
		Item.theItem.LEGENDARY_SCRAP:
			itemImage.texture = load("res://Textures/Citizens/Scrap/Legendary Scrap.png")
			mainBackground.texture = load("res://Textures/UI/Item/Copper Gem UI.png")
		Item.theItem.UNSEEN_SCRAP:
			itemImage.texture = load("res://Textures/Citizens/Scrap/Unseen Scrap.png")
			mainBackground.texture = load("res://Textures/UI/Item/Copper Gem UI.png")


func _on_selll_button_pressed() -> void:
	$SellSliderBackground/AmountLabel.text = "[color=gray]x" + str(item.amount) + "[/color]"
	slider.value = 0
	slider.max_value = item.amount
	sellMenu.show()

func _on_cancel_button_pressed() -> void:
	sellMenu.hide()
	convertScrapBackground.hide()

func _on_h_slider_value_changed(value: float) -> void:
	sliderItemAmount.text = "[color=white]x" + str(item.amount - slider.value) + "[/color]"
	sellAmountText.text = "[color=gold]$" + str(item.moneyValue * slider.value) + "[/color]"


func _on_sell_button_pressed() -> void:
	CityManager.sellItem(item,slider.value,item.moneyValue)
	sellMenu.hide()

func refresh():
	$SellSliderBackground/AmountLabel.text = "[color=white]x" + str(item.amount) + "[/color]"
	slider.max_value = item.amount
	itemAmountLabel.text = "Amount: [color=gray]x" + str(item.amount) + "[/color]"
	itemValueLabel.text = "Value: [color=gold]$" + str(int(item.moneyValue * item.amount)) + "[/color]"


func _on_convert_button_pressed() -> void:
	convertAmountPlateText.text = "[color=white]x" + str(item.amount) + "[/color]"
	convertSlider.value = 0
	convertSlider.max_value = item.amount
	convertMenu.show()


func _on_convert_h_slider_value_changed(value: float) -> void:
	convertAmountPlateText.text = "[color=white]x" + str(item.amount - convertSlider.value) + "[/color]"
	convertAmountText.text = "[color=blue]Energy: " + str(item.energyValue * convertSlider.value) + "[/color]"


func _on_cancel_convert_button_pressed() -> void:
	convertMenu.hide()


func _on_convert_confirm_button_pressed() -> void:
	CityManager.convertItem(item,convertSlider.value,item.energyValue)
	convertMenu.hide()


func _on_convert_scrap_button_pressed() -> void:
	scrapAmountPlateLabel.text = "[color=gray]x" + str(item.amount) + "[/color]"
	scrapSlider.value = 0
	scrapSlider.max_value = item.amount
	convertScrapBackground.show()



func _on_scrap_button_pressed() -> void:
	CityManager.scrapItem(item,scrapSlider.value,item.scrapValue)
	convertScrapBackground.hide()


func _on_scrap_slider_value_changed(value: float) -> void:
	scrapAmountPlateLabel.text = "[color=white]x" + str(item.amount - scrapSlider.value) + "[/color]"
	scrapAmountText.text = "[color=yellow]Scrap: " + str(item.scrapValue * scrapSlider.value) + "[/color]"
