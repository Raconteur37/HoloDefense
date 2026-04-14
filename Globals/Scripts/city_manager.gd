extends Node

# A signal is the only way ik how a global script like this can communicate to buildings
signal storageChanged()
signal citizenSpawned(citizen)

var itemMoneyValueDict : Dictionary = {}
var itemEnergyValueDict : Dictionary = {}

var startingCash : int = 1000
var startingEnergy : float = 100
var startingScrap : int = 50

var moneyGenerated : int = 1
var energyGenerated : float = 1.5
var scrapGenerated : int = 2

var currentMoney = startingCash
var currentEnergy = startingEnergy
var currentScrap = startingScrap

var generatorLevel : int = 1
var gemScraperLevel : int = 1
var cityLevel : int = 1 # This will increase as you generate more wealth and have more citizens and upgrade generators

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

func getMoneyItemValue(itemEnum):
	if itemMoneyValueDict.has(itemEnum):
		return itemMoneyValueDict.get(itemEnum)
	else:
		return -999999

func getEnergyItemValue(itemEnum):
	if itemEnergyValueDict.has(itemEnum):
		return itemEnergyValueDict.get(itemEnum)
	else:
		return -999999

func sellItem(item : Item,amountSelling : int,sellValue: int):
	if storage.has(item.actualItem):
		if amountSelling <= item.amount:
			currentMoney += amountSelling * sellValue
			storage[item.actualItem] = storage.get(item.actualItem) - amountSelling
			storageChanged.emit()
		else:
			push_error("selling more than what you have") # crash the game cus fuck you

func convertItem(item : Item,amountSelling : int,convertValue: float):
	if storage.has(item.actualItem):
		if amountSelling <= item.amount:
			currentEnergy += amountSelling * convertValue
			storage[item.actualItem] = storage.get(item.actualItem) - amountSelling
			storageChanged.emit()
		else:
			push_error("converting more than what you have") # crash the game cus fuck you

func getCurrentMoney():
	return currentMoney

func getCurrentEnergy():
	return currentEnergy

func getCurrentScrap():
	return currentScrap

func generateResources():
	currentMoney += moneyGenerated
	currentEnergy += energyGenerated
	currentScrap += scrapGenerated

func upgradeGenerator():
	generatorLevel += 1
	moneyGenerated += ceil(1*(pow(1.10,(generatorLevel-1))))
	energyGenerated += round((1*(pow(1.07,(generatorLevel-1))))*100) / 100
	scrapGenerated += ceil(1*(pow(1.08,(generatorLevel-1))))
