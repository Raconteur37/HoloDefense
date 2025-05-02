extends Node

var cityLevel : int = 1

var holoGenerator
var gemScraper

var storage : Dictionary = {"Copper Gem" : 100}

var citizens : Array = []

var citizensSelected : Array = []

var cityExperienceCap : float = 100



func openStorage():
	print(storage)
	# Loop through the dict and render the items as you find them


func generateBaseCitizenExperienceLevel():

	var lower_offset = randf_range(cityLevel * 0.1, cityLevel * 0.2)  # 10-20% reduction
	var lower_bound = max(0.0, cityLevel - lower_offset)

	var upper_offset = randf_range(cityLevel * 0.2, cityLevel * 0.4)  # 20-40% increase
	var upper_bound = cityLevel + upper_offset

	lower_bound = snappedf(lower_bound, 0.1)
	upper_bound = snappedf(upper_bound, 0.1)

	return [lower_bound, upper_bound]

func getHoloGeneratorLocation():
	return Vector2(get_tree().current_scene.find_child("HoloGenerator").global_position.x + randi_range(-100,100),get_tree().current_scene.find_child("HoloGenerator").global_position.y)

func getGemScraperLocation():
	return Vector2(get_tree().current_scene.find_child("GemFabricator").global_position.x + randi_range(-100,100),get_tree().current_scene.find_child("GemFabricator").global_position.y)

func getStorageItemAmount(itemName):
	if storage.has(itemName):
		return storage.get(itemName)

func getItemValue(itemName):
	var file = FileAccess.open("res://Config/Item Value.json",FileAccess.READ)
	var itemValueInfo = JSON.parse_string(file.get_as_text())
	return itemValueInfo.get(itemName)
	file.close()
