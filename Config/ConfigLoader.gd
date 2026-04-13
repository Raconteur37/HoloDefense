extends Node

# Item enum lookup table
var itemLookupDict : Dictionary = {
	"Copper Gem" : Item.theItem.COPPER_GEM,
	"Quartz Gem" : Item.theItem.QUARTZ_GEM,
	"Amethyst Gem" : Item.theItem.AMETHYST_GEM,
	"Diamond Gem" : Item.theItem.DIAMOND_GEM,
	"Galactite Gem" : Item.theItem.GALACTITE_GEM,
}

# This script loads when the game loads and properly sets up everything

func _ready() -> void:
	setupCityManagerItemDictionaries()

# Setup CityManager item value dictionaries
func setupCityManagerItemDictionaries(): 
	var file = FileAccess.open("res://Config/Item Value.json", FileAccess.READ)
	if not file:
		print("Error: Could not find config file!")
		return
		
	var json_data = JSON.parse_string(file.get_as_text())
	
	var moneyValues = {}
	var energyValues = {}
	
	var moneyData = json_data.get("Money", {})
	for itemName in moneyData.keys():
		if itemLookupDict.has(itemName):
			moneyValues[itemLookupDict[itemName]] = moneyData[itemName]
			
	var energyData = json_data.get("Energy", {})
	for itemName in energyData.keys():
		if itemLookupDict.has(itemName):
			energyValues[itemLookupDict[itemName]] = energyData[itemName]
			
	#print("Money Table (Enum keys): ", moneyValues)
	#print("Energy Table (Enum keys): ", energyValues)
	
	CityManager.itemMoneyValueDict = moneyValues.duplicate()
	CityManager.itemEnergyValueDict = energyValues.duplicate()
	
