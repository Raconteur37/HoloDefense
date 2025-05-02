extends Popup

var itemName
var itemAmount

var oneItemValue

@onready var itemNameLabel = $"TextureRect/Item Name"

@onready var slider = $SellSliderBackground/HSlider

@onready var sellMenu = $SellSliderBackground
@onready var sellSliderButton = $SellSliderBackground/HBoxContainer/SellButton/SellLabel
@onready var sliderItemAmount = $SellSliderBackground/AmountLabel
@onready var sellAmountText = $SellSliderBackground/SellAmountText

@onready var itemAmountLabel = $TextureRect/AmountLabel
@onready var itemValueLabel = $TextureRect/ValueLabel

func buildItem(itemName : String):
	match itemName:

		"Copper Gem":
			itemNameLabel.text = "Copper Gem"
			self.itemName = "Copper Gem"
			oneItemValue = CityManager.getItemValue(itemName)
			itemAmount = CityManager.getStorageItemAmount(itemName)
			itemValueLabel.text = "Value: [color=gold]$" + str(int(oneItemValue * itemAmount)) + "[/color]"


func _on_popup_hide() -> void:
	queue_free()

func _on_selll_button_pressed() -> void:
	$SellSliderBackground/AmountLabel.text = "[color=gray]x" + str(itemAmount) + "[/color]"
	slider.value = 0
	slider.max_value = itemAmount
	sellMenu.show()

func _on_cancel_button_pressed() -> void:
	sellMenu.hide()

func _on_h_slider_value_changed(value: float) -> void:
	sliderItemAmount.text = "[color=gray]x" + str(itemAmount - slider.value) + "[/color]"
	sellAmountText.text = "[color=gold]$" + str(oneItemValue * slider.value) + "[/color]"
