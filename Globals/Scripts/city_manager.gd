extends Node

# A signal is the only way ik how a global script like this can communicate to buildings
signal storageChanged()
signal citizenSpawned(citizen)

var itemMoneyValueDict : Dictionary = {}
var itemEnergyValueDict : Dictionary = {}
var itemScrapValueDict : Dictionary = {}

var autoSellCommonGem : bool = false
var autoSellRareGem : bool = false
var autoSellSuperRareGem : bool = false
var autoSellLegendaryGem : bool = false
var autoSellUnseenGem : bool = false

var autoConvertCommonGem : bool = false
var autoConvertRareGem : bool = false
var autoConvertSuperRareGem : bool = false
var autoConvertLegendaryGem : bool = false
var autoConvertUnseenGem : bool = false

var startingCash
var startingEnergy
var startingScrap

var moneyGenerated
var energyGenerated
var scrapGenerated

var currentMoney
var currentEnergy
var currentScrap

var generatorLevel : int = 1
var gemScraperLevel : int = 1
var materialAtomizerLevel : int = 1
var cityLevel : int = 1 # This will increase as you generate more wealth and have more citizens and upgrade generators

var holoGenerator
var gemScraper

var currentItemPopup = null
var currentItemName = null

var storage : Dictionary = {}

var citizens : Array = []

var citizensSelected : Array = []

var cityExperienceCap : float = 100

var gemChances = {
Item.theItem.COPPER_GEM : -1,
Item.theItem.QUARTZ_GEM : -1,
Item.theItem.AMETHYST_GEM : -1,
Item.theItem.DIAMOND_GEM : -1,
Item.theItem.GALACTITE_GEM : -1}

var scrapChances = {
Item.theItem.COMMON_SCRAP : -1,
Item.theItem.RARE_SCRAP : -1,
Item.theItem.SUPER_RARE_SCRAP : -1,
Item.theItem.LEGENDARY_SCRAP : -1,
Item.theItem.UNSEEN_SCRAP : -1}

var scraperStartWeights = []
var scraperEndWeights = []
var maxScraperLevel

var atomizerStartWeights = []
var atomizerEndWeights = []
var maxAtomizerLevel

@onready var autoSellMap = {
	Item.theItem.COPPER_GEM: "autoSellCommonGem",
	Item.theItem.QUARTZ_GEM: "autoSellRareGem",
	Item.theItem.AMETHYST_GEM: "autoSellSuperRareGem",
	Item.theItem.DIAMOND_GEM: "autoSellLegendaryGem",
	Item.theItem.GALACTITE_GEM: "autoSellUnseenGem"
}

@onready var autoConvertMap = {
	Item.theItem.COPPER_GEM: "autoConvertCommonGem",
	Item.theItem.QUARTZ_GEM: "autoConvertRareGem",
	Item.theItem.AMETHYST_GEM: "autoConvertSuperRareGem",
	Item.theItem.DIAMOND_GEM: "autoConvertLegendaryGem",
	Item.theItem.GALACTITE_GEM: "autoConvertUnseenGem"
}

func _ready() -> void:
	# Testing
	currentMoney = startingCash
	currentEnergy = startingEnergy
	currentScrap = startingScrap
	updateGemChanceWeights()
	updateScrapChanceWeights()
	pass

func addItem(item):
	if autoSellMap.has(item): # Auto sell based on map booleans
		var varName = autoSellMap[item]
		if get(varName) == true:
			autoSell(item)
			return
	if autoConvertMap.has(item): 
		var varName = autoConvertMap[item]
		if get(varName) == true:
			autoConvert(item)
			return
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

func getMaterialAtomizerLocation():
	return Vector2(get_tree().current_scene.find_child("MaterialAtomizer").global_position.x + randi_range(-100,100),get_tree().current_scene.find_child("MaterialAtomizer").global_position.y)

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

func getScrapItemValue(itemEnum):
	if itemScrapValueDict.has(itemEnum):
		return itemScrapValueDict.get(itemEnum)
	else:
		return -999999

func scrapItem(item : Item,amountScrapping : int,scrapValue: int):
	if storage.has(item.actualItem):
		if amountScrapping <= item.amount:
			currentScrap += amountScrapping * scrapValue
			storage[item.actualItem] = storage.get(item.actualItem) - amountScrapping
			storageChanged.emit()
		else:
			push_error("selling more than what you have")

func sellItem(item : Item,amountSelling : int,sellValue: int):
	if storage.has(item.actualItem):
		if amountSelling <= item.amount:
			currentMoney += amountSelling * sellValue
			storage[item.actualItem] = storage.get(item.actualItem) - amountSelling
			storageChanged.emit()
		else:
			push_error("selling more than what you have") # crash the game cus screw	 you

# creating a special auto sell cus its easier for now
func autoSell(item):
	currentMoney += itemMoneyValueDict.get(item)

func autoConvert(item):
	currentEnergy += itemEnergyValueDict.get(item)

func massAutoSell(item : Item.theItem):
	if storage.get(item) != null:
		var amount = storage.get(item)
		currentMoney += itemMoneyValueDict.get(item) * amount
		storage[item] = 0
		storageChanged.emit()

func massAutoConvert(item : Item.theItem):
	if storage.get(item) != null:
		var amount = storage.get(item)
		currentEnergy += itemEnergyValueDict.get(item) * amount
		storage[item] = 0
		storageChanged.emit()

func convertItem(item : Item,amountSelling : int,convertValue: float):
	if storage.has(item.actualItem):
		if amountSelling <= item.amount:
			currentEnergy += amountSelling * convertValue
			storage[item.actualItem] = storage.get(item.actualItem) - amountSelling
			storageChanged.emit()
		else:
			push_error("converting more than what you have") # crash the game cus fuck you

# need to create a probability distribution (linear) that is skewed right as you upgrade it
func updateGemChanceWeights():
	var weights = [0.0, 0.0, 0.0, 0.0, 0.0]
	
	var progress = float(gemScraperLevel - 1) / (maxScraperLevel-1)
	#print("PROGRESS VALUE: ", progress)
	
	var startDistribution = scraperStartWeights
	var endDistribution = scraperEndWeights

	for i in range(5):
		# linear interpolate so we can slowly move to the final points on the graph (end dist)
		weights[i] = lerp(startDistribution[i], endDistribution[i], progress)

	# normalize the distribution so it adds up to 100%
	var totalWeight = 0.0
	for w in weights:
		totalWeight += w

	for i in range(5):
		weights[i] = snapped((weights[i] / totalWeight) * 100.0, 0.01)
	
	var keys = gemChances.keys()

	for i in range(keys.size()):
		gemChances[keys[i]] = weights[i]
	
	#print(gemChances)
	#print("LEVEL: ", gemScraperLevel, " PROGRESS: ", progress)
	#print("WEIGHTS: ", weights)

func calcGemChanceWeights(cityLevelTest):
	var weights = [0.0, 0.0, 0.0, 0.0, 0.0]
	
	var progress = float(cityLevelTest - 1) / 49.0
	#print("PROGRESS VALUE: ", progress)
	
	var startDistribution = scraperStartWeights
	var endDistribution = scraperEndWeights

	for i in range(5):
		# linear interpolate so we can slowly move to the final points on the graph (end dist)
		weights[i] = lerp(startDistribution[i], endDistribution[i], progress)

	# normalize the distribution so it adds up to 100%
	var totalWeight = 0.0
	for w in weights:
		totalWeight += w

	for i in range(5):
		weights[i] = snapped((weights[i] / totalWeight) * 100.0, 0.01)
	
	var keys = gemChances.keys()

	var chancesCopy = gemChances.duplicate()

	for i in range(keys.size()):
		chancesCopy[keys[i]] = weights[i]
	
	return chancesCopy
	#print(gemChances)
	#print("LEVEL: ", gemScraperLevel, " PROGRESS: ", progress)
	#print("WEIGHTS: ", weights)

func updateScrapChanceWeights():
	var weights = [0.0, 0.0, 0.0, 0.0, 0.0]
	
	var progress = float(materialAtomizerLevel - 1) / (maxAtomizerLevel-1)
	#print("PROGRESS VALUE: ", progress)
	
	var startDistribution = atomizerStartWeights
	var endDistribution = atomizerEndWeights

	for i in range(5):
		weights[i] = lerp(startDistribution[i], endDistribution[i], progress)

	var totalWeight = 0.0
	for w in weights:
		totalWeight += w

	for i in range(5):
		weights[i] = snapped((weights[i] / totalWeight) * 100.0, 0.01)
	
	var keys = scrapChances.keys()

	for i in range(keys.size()):
		scrapChances[keys[i]] = weights[i]


func addCitizen(cit : Citizen):
	citizens.append(cit)

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
