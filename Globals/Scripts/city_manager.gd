extends Node

# A signal is the only way ik how a global script like this can communicate to buildings
signal storageChanged()
signal citizenSpawned(citizen)

var itemMoneyValueDict : Dictionary = {}
var itemEnergyValueDict : Dictionary = {}
var itemScrapValueDict : Dictionary = {}

var baseItemMoneyValueDict : Dictionary = {}
var baseItemEnergyValueDict : Dictionary = {}
var baseItemScrapValueDict : Dictionary = {}

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

var autoSellCommonScrap : bool = false
var autoSellRareScrap : bool = false
var autoSellSuperRareScrap : bool = false
var autoSellLegendaryScrap : bool = false
var autoSellUnseenScrap : bool = false

var autoConvertCommonScrap : bool = false
var autoConvertRareScrap : bool = false
var autoConvertSuperRareScrap : bool = false
var autoConvertLegendaryScrap : bool = false
var autoConvertUnseenScrap : bool = false

var startingCash
var startingEnergy
var startingScrap

var moneyGenerated
var energyGenerated
var scrapGenerated

var currentMoney
var currentEnergy
var currentScrap

var moneyScale
var energyScale
var scrapScale

var itemScaleFactor

var researchTimeScale
var researchTimeMinScale

var fabricatorCostMultiplier
var baseFabricatorSlotCost
var fabricatorSlotCost

var generatorLevel : int = 1
var gemScraperLevel : int = 1
var materialAtomizerLevel : int = 1
var researchLabLevel : int = 1
var cityLevel : int = 1 # This will increase as you generate more wealth and have more citizens and upgrade generators

var holoGenerator
var gemScraper

var currentItemPopup = null
var currentItemName = null

var storage : Dictionary = {}

var citizensGenerated = 0

var citizens : Array = []

var citizensSelected : Array = []

var cityExperienceCap : float = 100

var baseCitizenGenCost
var citizenGenCost
var citizenCostMultiplier

var baseGeneratorUpgradeCost
var generatorUpgradeCost
var generatorCostMultiplier

var baseScraperUpgradeCost
var scraperUpgradeCost
var scraperCostMultiplier
var baseScraperProductionTime

var baseAtomizerUpgradeCost
var atomizerUpgradeCost
var atomizerCostMultiplier
var baseAtomizerProductionTime

var baseResearchLabSlotCost
var researchLabSlotCost
var researchLabCostMultiplier
var researchMaxLevel
var researchBaseCost
var researchCostScaling


var milestoneMoney
var milestoneEnergy
var milestoneScrap

var milestoneMoneyMax
var milestoneEnergyMax
var milestoneScrapMax

var assignCit = false

var cityXpWeights = {
	"purchase_upgrade": 50,
	"spawn_citizen": 20,
	"milestone": 10,
	"generate_resource": .1
}

var cityXP = 0
var baseMaxCityXp
var cityMaxXpScale
var cityMaxXP

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
	Item.theItem.GALACTITE_GEM: "autoSellUnseenGem",
	Item.theItem.COMMON_SCRAP: "autoSellCommonScrap",
	Item.theItem.RARE_SCRAP: "autoSellRareScrap",
	Item.theItem.SUPER_RARE_SCRAP: "autoSellSuperRareScrap",
	Item.theItem.LEGENDARY_SCRAP: "autoSellLegendaryScrap",
	Item.theItem.UNSEEN_SCRAP: "autoSellUnseenScrap"
}

@onready var autoConvertMap = {
	Item.theItem.COPPER_GEM: "autoConvertCommonGem",
	Item.theItem.QUARTZ_GEM: "autoConvertRareGem",
	Item.theItem.AMETHYST_GEM: "autoConvertSuperRareGem",
	Item.theItem.DIAMOND_GEM: "autoConvertLegendaryGem",
	Item.theItem.GALACTITE_GEM: "autoConvertUnseenGem",
}

@onready var autoScrapMap = {
	Item.theItem.COMMON_SCRAP: "autoConvertCommonScrap",
	Item.theItem.RARE_SCRAP: "autoConvertRareScrap",
	Item.theItem.SUPER_RARE_SCRAP: "autoConvertSuperRareScrap",
	Item.theItem.LEGENDARY_SCRAP: "autoConvertLegendaryScrap",
	Item.theItem.UNSEEN_SCRAP: "autoConvertUnseenScrap"
}

func _ready() -> void:
	# Testing
	currentMoney = startingCash
	currentEnergy = startingEnergy
	currentScrap = startingScrap
	#currentMoney = 999999
	#currentEnergy = 999999
	currentScrap = 999999
	updateGemChanceWeights()
	updateScrapChanceWeights()
	citizenGenCost = baseCitizenGenCost
	generatorUpgradeCost = baseGeneratorUpgradeCost
	scraperUpgradeCost = baseScraperUpgradeCost
	atomizerUpgradeCost = baseAtomizerUpgradeCost
	researchLabSlotCost = baseResearchLabSlotCost
	fabricatorSlotCost = baseFabricatorSlotCost
	#updateGenCitizenCost()
	#updateGeneratorUpgradeCost()
	baseItemMoneyValueDict = itemMoneyValueDict.duplicate()
	baseItemEnergyValueDict = itemEnergyValueDict.duplicate()
	baseItemScrapValueDict = itemScrapValueDict.duplicate()
	
	cityMaxXP = baseMaxCityXp
	
	cityXP = 0
	milestoneMoney = 0
	milestoneEnergy = 0
	milestoneScrap = 0

func addItem(item):
	#cityLevelUp()
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
	if autoScrapMap.has(item): 
		var varName = autoScrapMap[item]
		if get(varName) == true:
			autoScrap(item)
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
	return Vector2(get_tree().current_scene.find_child("GemScraper").global_position.x + randi_range(-100,100),get_tree().current_scene.find_child("GemScraper").global_position.y)

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
			var val = amountScrapping * scrapValue
			currentScrap += val
			manageMilestone("scrap",val)
			storage[item.actualItem] = storage.get(item.actualItem) - amountScrapping
			storageChanged.emit()
		else:
			push_error("scrapping more than what you have")

func sellItem(item : Item,amountSelling : int,sellValue: int):
	if storage.has(item.actualItem):
		if amountSelling <= item.amount:
			var val = amountSelling * sellValue
			currentMoney += val
			manageMilestone("money",val)
			storage[item.actualItem] = storage.get(item.actualItem) - amountSelling
			storageChanged.emit()
		else:
			push_error("selling more than what you have") # crash the game cus screw	 you

# creating a special auto sell cus its easier for now
func autoSell(item):
	var moneyVal = itemMoneyValueDict.get(item)
	currentMoney += moneyVal
	manageMilestone("money",moneyVal)

func autoConvert(item):
	var energyVal = itemEnergyValueDict.get(item)
	currentEnergy += energyVal
	currentEnergy = GameManager.round_to_dec(currentEnergy,2)
	manageMilestone("energy",energyVal)

func autoScrap(item):
	var scrapVal = itemScrapValueDict.get(item)
	currentScrap += scrapVal
	manageMilestone("scrap",scrapVal)

func massAutoSell(item : Item.theItem):
	if storage.get(item) != null:
		var amount = storage.get(item)
		var val = itemMoneyValueDict.get(item) * amount
		currentMoney += val
		manageMilestone("money",val)
		storage[item] = 0
		storageChanged.emit()

func massAutoConvert(item : Item.theItem):
	if storage.get(item) != null:
		var amount = storage.get(item)
		var val = itemEnergyValueDict.get(item) * amount
		currentEnergy += val
		currentEnergy = GameManager.round_to_dec(currentEnergy,2)
		manageMilestone("energy",val)
		storage[item] = 0
		storageChanged.emit()

func massAutoScrap(item : Item.theItem):
	if storage.get(item) != null:
		var amount = storage.get(item)
		var val = itemScrapValueDict.get(item) * amount
		currentScrap += val
		manageMilestone("scrap",val)
		storage[item] = 0
		storageChanged.emit()

func convertItem(item : Item,amountSelling : int,convertValue: float):
	if storage.has(item.actualItem):
		if amountSelling <= item.amount:
			var val = amountSelling * convertValue
			currentEnergy += val
			currentEnergy = GameManager.round_to_dec(currentEnergy,2)
			manageMilestone("energy",val)
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

func calcAtomizerChanceWeights(cityLevelTest):
	var weights = [0.0, 0.0, 0.0, 0.0, 0.0]
	
	var progress = float(cityLevelTest - 1) / 49.0
	#print("PROGRESS VALUE: ", progress)
	
	var startDistribution = atomizerStartWeights
	var endDistribution = atomizerEndWeights

	for i in range(5):
		# linear interpolate so we can slowly move to the final points on the graph (end dist)
		weights[i] = lerp(startDistribution[i], endDistribution[i], progress)

	# normalize the distribution so it adds up to 100%
	var totalWeight = 0.0
	for w in weights:
		totalWeight += w

	for i in range(5):
		weights[i] = snapped((weights[i] / totalWeight) * 100.0, 0.01)
	
	var keys = scrapChances.keys()

	var chancesCopy = scrapChances.duplicate()

	for i in range(keys.size()):
		chancesCopy[keys[i]] = weights[i]
	
	return chancesCopy
	#print(gemChances)
	#print("LEVEL: ", gemScraperLevel, " PROGRESS: ", progress)
	#print("WEIGHTS: ", weights)

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
	moneyGenerated += ceil(1*(pow(moneyScale,(generatorLevel-1))))
	energyGenerated += round((1*(pow(energyScale,(generatorLevel-1))))*100) / 100
	scrapGenerated += ceil(1*(pow(scrapScale,(generatorLevel-1))))
	updateGeneratorUpgradeCost()

func updateGenCitizenCost():
	citizenGenCost = roundf(round(100 * (baseCitizenGenCost * (pow(citizenCostMultiplier,citizensGenerated)))) / 100)

func updateGeneratorUpgradeCost():
	generatorUpgradeCost = round(round(100 * (baseGeneratorUpgradeCost * (pow(generatorCostMultiplier,generatorLevel)))) / 100)

func updateScraperUpgradeCost():
	scraperUpgradeCost = round(round(100 * (baseScraperUpgradeCost * (pow(scraperCostMultiplier,gemScraperLevel)))) / 100)

func updateAtomizerUpgradeCost():
	atomizerUpgradeCost = round(round(100 * (baseAtomizerUpgradeCost * (pow(atomizerCostMultiplier,materialAtomizerLevel)))) / 100)


func updateAllItemValues(): 
	
	for item in baseItemMoneyValueDict.keys():
		var boost = 1.0 + (cityLevel * itemScaleFactor)
		itemMoneyValueDict[item] = int(baseItemMoneyValueDict[item] * boost)
		

	for item in baseItemScrapValueDict.keys():
		var boost = 1.0 + (cityLevel * itemScaleFactor)
		itemScrapValueDict[item] = int(baseItemScrapValueDict[item] * boost)
		

	for item in baseItemEnergyValueDict.keys():
		var boost = 1.0 + (cityLevel * itemScaleFactor)
		itemEnergyValueDict[item] = baseItemEnergyValueDict[item] * boost

func manageMilestone(type : String, val):
	if type == "money":
		milestoneMoney += val
		if milestoneMoney >= milestoneMoneyMax:
			addCityXp("milestone")
			milestoneMoney = milestoneMoney - milestoneMoneyMax
	if type == "energy":
		milestoneEnergy += val
		if milestoneEnergy >= milestoneEnergyMax:
			addCityXp("milestone")
			milestoneEnergy = milestoneEnergy - milestoneEnergyMax
	if type == "scrap":
		milestoneScrap += val
		if milestoneScrap >= milestoneScrapMax:
			addCityXp("milestone")
			milestoneScrap = milestoneScrap - milestoneScrapMax

func addCityXp(type : String):
	var xpAmount = cityXpWeights.get(type)

	cityXP += xpAmount
	
	if cityXP >= cityMaxXP:
		cityXP = cityMaxXP - cityXP
		cityLevelUp()
		updateCityMaxXP()

func updateCityMaxXP():
	cityMaxXP = baseMaxCityXp * pow(cityLevel, cityMaxXpScale)

func cityLevelUp():
	SoundManager.cityLevelUp()
	cityLevel += 1
	updateAllItemValues()
	storageChanged.emit()
	
	# play popup and sound
	var popup = load("res://Globals/Scene/Popup.tscn")
	popup = popup.instantiate()
	
	var canvasLayer
	
	if get_tree().current_scene is not CanvasLayer:
		for child in get_tree().current_scene.get_children():
			if child is CanvasLayer:
				canvasLayer = child
				break
	else:
		canvasLayer = get_tree().current_scene
		
	canvasLayer.add_child(popup)
	popup.cityLevelUp()

func addTurretTempLevel(turretID,amount):
	if GameManager.turretTempLevels.has(turretID):
		GameManager.turretTempLevels[turretID] = GameManager.turretTempLevels.get(turretID) + amount
	else:
		GameManager.turretTempLevels[turretID] = amount
	# TODO ADD A SIGNAL HERE TO UPDATE ALL EXISTING TURRETS


func reset():
	PlacementManager.reset()
	for citizen in citizens:
		if is_instance_valid(citizen):
			citizen.queue_free()

	citizens.clear()
	currentMoney = startingCash
	currentEnergy = startingEnergy
	currentScrap = startingScrap

	# Milestones
	milestoneMoney = 0
	milestoneEnergy = 0
	milestoneScrap = 0

	# City
	cityLevel = 1
	cityXP = 0
	cityMaxXP = baseMaxCityXp

	# Building levels
	generatorLevel = 1
	gemScraperLevel = 1
	materialAtomizerLevel = 1
	researchLabLevel = 1

	# Costs
	citizenGenCost = baseCitizenGenCost
	generatorUpgradeCost = baseGeneratorUpgradeCost
	scraperUpgradeCost = baseScraperUpgradeCost
	atomizerUpgradeCost = baseAtomizerUpgradeCost
	researchLabSlotCost = baseResearchLabSlotCost
	fabricatorSlotCost = baseFabricatorSlotCost

	# Generation
	moneyGenerated = ceil(1*(pow(moneyScale,(generatorLevel-1))))
	energyGenerated = round((1*(pow(energyScale,(generatorLevel-1))))*100) / 100
	scrapGenerated = ceil(1*(pow(scrapScale,(generatorLevel-1))))

	# Item values back to base
	itemMoneyValueDict = baseItemMoneyValueDict.duplicate()
	itemEnergyValueDict = baseItemEnergyValueDict.duplicate()
	itemScrapValueDict = baseItemScrapValueDict.duplicate()

	# Storage and citizens
	storage.clear()
	citizens.clear()
	citizensSelected.clear()
	citizensGenerated = 0

	# Auto sell/convert flags — reset to off
	autoSellCommonGem = false
	autoSellRareGem = false
	autoSellSuperRareGem = false
	autoSellLegendaryGem = false
	autoSellUnseenGem = false

	autoConvertCommonGem = false
	autoConvertRareGem = false
	autoConvertSuperRareGem = false
	autoConvertLegendaryGem = false
	autoConvertUnseenGem = false

	autoSellCommonScrap = false
	autoSellRareScrap = false
	autoSellSuperRareScrap = false
	autoSellLegendaryScrap = false
	autoSellUnseenScrap = false

	autoConvertCommonScrap = false
	autoConvertRareScrap = false
	autoConvertSuperRareScrap = false
	autoConvertLegendaryScrap = false
	autoConvertUnseenScrap = false

	# Recalculate chance weights from base levels
	updateGemChanceWeights()
	updateScrapChanceWeights()

	storageChanged.emit()
