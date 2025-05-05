extends Popup

var item : Item

@onready var itemNameLabel = $"TextureRect/Item Name"

@onready var slider = $SellSliderBackground/HSlider

@onready var sellMenu = $SellSliderBackground
@onready var sellSliderButton = $SellSliderBackground/HBoxContainer/SellButton/SellLabel
@onready var sliderItemAmount = $SellSliderBackground/AmountLabel
@onready var sellAmountText = $SellSliderBackground/SellAmountText

@onready var itemAmountLabel = $TextureRect/AmountLabel
@onready var itemValueLabel = $TextureRect/ValueLabel

@onready var itemImage = $TextureRect/ItemImage

func setItem(itemName):

	item = CityManager.getStorageItem(itemName)

	itemImage.texture = setItemImage(itemName)
	itemNameLabel.text = item.itemName
	itemAmountLabel.text = "Amount: [color=gray]x" + str(item.amount) + "[/color]"
	itemValueLabel.text = "Value: [color=gold]$" + str(int(item.moneyValue * item.amount)) + "[/color]"

func setItemImage(itemName):

	match itemName:

		"Copper Gem":
			return load("res://Textures/Citizens/Gems/copperGem.png")
		"Quartz Gem":
			return load("res://Textures/Citizens/Gems/Quartz.png")

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
	sellMenu.hide()
