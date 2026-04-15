extends Node

# Item enum lookup table
var itemLookupDict : Dictionary = {
	"Copper Gem" : Item.theItem.COPPER_GEM,
	"Quartz Gem" : Item.theItem.QUARTZ_GEM,
	"Amethyst Gem" : Item.theItem.AMETHYST_GEM,
	"Diamond Gem" : Item.theItem.DIAMOND_GEM,
	"Galactite Gem" : Item.theItem.GALACTITE_GEM,
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
		CityManager.startingCash = citySettings.get("StartingCash", 1000)
		CityManager.startingEnergy = citySettings.get("StartingEnergy", 100.0)
		CityManager.startingScrap = citySettings.get("StartingScrap", 50)
		CityManager.moneyGenerated = citySettings.get("MoneyGenerated", 1)
		CityManager.energyGenerated = citySettings.get("EnergyGenerated", 1.5)
		CityManager.scrapGenerated = citySettings.get("ScrapGenerated", 2)

	# -=HANDLE GEM VALUES=-
	var gemValues = json_data.get("GemValues", {})
	
	var moneyValues = {}
	var energyValues = {}
	
	# Parse Money
	var moneyData = gemValues.get("Money", {})
	for itemName in moneyData.keys():
		if itemLookupDict.has(itemName):
			moneyValues[itemLookupDict[itemName]] = moneyData[itemName]
			
	# Parse Energy
	var energyData = gemValues.get("Energy", {})
	for itemName in energyData.keys():
		if itemLookupDict.has(itemName):
			energyValues[itemLookupDict[itemName]] = energyData[itemName]
	
	CityManager.itemMoneyValueDict = moneyValues
	CityManager.itemEnergyValueDict = energyValues

	# -=HANDLE SCRAPER SETTINGS=-
	var scraperSettings = json_data.get("ScraperSettings", {})
	if not scraperSettings.is_empty():
		CityManager.scraperStartWeights = scraperSettings.get("StartWeights", [])
		CityManager.scraperEndWeights = scraperSettings.get("EndWeights", [])
		CityManager.maxScraperLevel = scraperSettings.get("MaxLevel", 50)

	print("Config setup done no errors")
