extends Node

# Item enum lookup table
var itemLookupDict : Dictionary = {
	"Copper Gem" : Item.theItem.COPPER_GEM,
	"Quartz Gem" : Item.theItem.QUARTZ_GEM,
	"Amethyst Gem" : Item.theItem.AMETHYST_GEM,
	"Diamond Gem" : Item.theItem.DIAMOND_GEM,
	"Galactite Gem" : Item.theItem.GALACTITE_GEM,
	"Common Scrap": Item.theItem.COMMON_SCRAP,
	"Rare Scrap": Item.theItem.RARE_SCRAP,
	"Super Rare Scrap": Item.theItem.SUPER_RARE_SCRAP,
	"Legendary Scrap": Item.theItem.LEGENDARY_SCRAP,
	"Unseen Scrap": Item.theItem.UNSEEN_SCRAP,
}

func _ready() -> void:
	setupCityManagerItemDictionaries()

func setupCityManagerItemDictionaries(): 
	var file = FileAccess.open("res://Config/Holo City Info.json", FileAccess.READ)
	if not file:
		print("Error: Could not find config file!")
		return
		
	var json_data = JSON.parse_string(file.get_as_text())
	if json_data == null:
		print("Error: Failed to parse JSON!")
		return


	var citySettings = json_data.get("HoloCitySettings", {})
	if not citySettings.is_empty():
		CityManager.startingCash = citySettings.get("StartingCash", -99)
		CityManager.startingEnergy = citySettings.get("StartingEnergy", 100.0)
		CityManager.startingScrap = citySettings.get("StartingScrap", 50)
		CityManager.moneyGenerated = citySettings.get("MoneyGenerated", 1)
		CityManager.energyGenerated = citySettings.get("EnergyGenerated", 1.5)
		CityManager.scrapGenerated = citySettings.get("ScrapGenerated", 2)
		CityManager.moneyScale = citySettings.get("MoneyScale", -99)
		CityManager.energyScale = citySettings.get("EnergyScale", -99)
		CityManager.scrapScale = citySettings.get("ScrapScale",-99)
		CityManager.baseCitizenGenCost = citySettings.get("BaseGenerateCitizenCost",-99)
		CityManager.citizenCostMultiplier = citySettings.get("CitizenGenerateCostScale",-99)
		CityManager.itemScaleFactor = citySettings.get("ItemScaleFactor",-99)
		CityManager.baseGeneratorUpgradeCost = citySettings.get("GeneratorUpgradeBaseCost", -99)
		CityManager.generatorCostMultiplier = citySettings.get("GeneratorUpgradeCostScale", -99)
	
	print(CityManager.moneyScale)

	# -=HANDLE GEM VALUES=-
	var gemValues = json_data.get("GemValues", {})
	
	var moneyValues = {}
	var energyValues = {}
	
	var moneyData = gemValues.get("Money", {})
	for itemName in moneyData.keys():
		if itemLookupDict.has(itemName):
			moneyValues[itemLookupDict[itemName]] = moneyData[itemName]
			
	var energyData = gemValues.get("Energy", {})
	for itemName in energyData.keys():
		if itemLookupDict.has(itemName):
			energyValues[itemLookupDict[itemName]] = energyData[itemName]
	
	CityManager.itemMoneyValueDict = moneyValues
	CityManager.itemEnergyValueDict = energyValues

	# -=HANDLE SCRAP VALUES=-
	var scrapValues = json_data.get("ScrapValues", {})

	var sMoneyValues = {}
	var sScrapValues = {}

	# Parse Scrap -> Money values
	var scrapMoneyData = scrapValues.get("Money", {})
	for itemName in scrapMoneyData.keys():
		if itemLookupDict.has(itemName):
			sMoneyValues[itemLookupDict[itemName]] = scrapMoneyData[itemName]
			
	# Parse Scrap -> Scrap resource values
	var scrapResourceData = scrapValues.get("Scrap", {})
	for itemName in scrapResourceData.keys():
		if itemLookupDict.has(itemName):
			sScrapValues[itemLookupDict[itemName]] = scrapResourceData[itemName]

	CityManager.itemMoneyValueDict.merge(sMoneyValues)
	CityManager.itemScrapValueDict = sScrapValues

	# -=HANDLE SCRAPER SETTINGS=-
	var scraperSettings = json_data.get("ScraperSettings", {})
	if not scraperSettings.is_empty():
		CityManager.scraperStartWeights = scraperSettings.get("StartWeights", [])
		CityManager.scraperEndWeights = scraperSettings.get("EndWeights", [])
		CityManager.maxScraperLevel = scraperSettings.get("MaxLevel", 50)
		CityManager.baseScraperUpgradeCost = scraperSettings.get("BaseUpgradeCost",-99)
		CityManager.scraperCostMultiplier = scraperSettings.get("CostScaling",99)


	# -=HANDLE ATOMZIER SETTINGS=-
	var atomzierSettings = json_data.get("AtomizerSettings", {})
	if not atomzierSettings.is_empty():
		CityManager.atomizerStartWeights = atomzierSettings.get("StartWeights", [])
		CityManager.atomizerEndWeights = atomzierSettings.get("EndWeights", [])
		CityManager.maxAtomizerLevel = atomzierSettings.get("MaxLevel", 50)
		CityManager.baseAtomizerUpgradeCost = scraperSettings.get("BaseUpgradeCost",-99)
		CityManager.atomizerCostMultiplier = scraperSettings.get("CostScaling",99)

	print("Config setup done no errors")
