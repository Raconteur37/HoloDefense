extends Node

# A signal is the only way ik how a global script like this can communicate to buildings
signal storageChanged()

var startingCash : int = 1000
var startingEnergy : int = 100
var startingScrap : int = 50

var currentMoney = startingCash
var currentEnergy = startingEnergy
var currentScrap = startingScrap

var cityLevel : int = 1

var holoGenerator
var gemScraper

var currentItemPopup = null
var currentItemName = null

var storage : Dictionary = {}

var citizens : Array = []

var citizensSelected : Array = []

var cityExperienceCap : float = 100

func _ready() -> void:
	# Testing
	pass

func addItem(item):
	if storage.has(item):
		storage[item] += 1
	else:
		storage[item] = 1
	storageChanged.emit()

func removeItemFromStorage(itemName):
	if storage.has(itemName):
		storage.erase(itemName)


func generateBaseCitizenExperienceLevel():

	var lower_offset = randf_range(cityLevel * 0.1, cityLevel * 0.2)  # 10-20% reduction
	var lower_bound = max(0.0, cityLevel - lower_offset)

	var upper_offset = randf_range(cityLevel * 0.2, cityLevel * 0.4)  # 20-40% increase
	var upper_bound = cityLevel + upper_offset

	lower_bound = snappedf(lower_bound, 0.1)
	upper_bound = snappedf(upper_bound, 0.1)

	return [lower_bound, upper_bound]

func getHoloGeneratorLocation():
	return Vector2(get_tree().current_scene.find_child("HoloGenerator").find_child("Work Area").global_position.x + randi_range(-100,100),get_tree().current_scene.find_child("HoloGenerator").find_child("Work Area").global_position.y)

func getGemScraperLocation():
	return Vector2(get_tree().current_scene.find_child("GemFabricator").global_position.x + randi_range(-100,100),get_tree().current_scene.find_child("GemFabricator").global_position.y)

func getStorageItem(itemName):
	if storage.has(itemName):
		return storage.get(itemName)

func getItemValue(itemName): # This is shit I should do it once on load and never again but not rn cus im lazy
	var file = FileAccess.open("res://Config/Item Value.json",FileAccess.READ)
	var itemValueInfo = JSON.parse_string(file.get_as_text())
	file.close()
	return itemValueInfo["Money"].get(itemName)

func sellItem(item : Item,amountSelling : int,sellValue: int):
	if storage.has(item.actualItem):
		if amountSelling <= item.amount:
			currentMoney += amountSelling * sellValue
			storage[item.actualItem] = storage.get(item.actualItem) - amountSelling
			storageChanged.emit()
		else:
			push_error("selling more than what you have") # crash the game cus fuck you


func getCurrentMoney():
	return currentMoney

func getCurrentEnergy():
	return currentEnergy

func getCurrentScrap():
	return currentScrap
