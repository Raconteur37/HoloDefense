extends Control

var workArea
var collisionArea

var citizenGenGrid : GridContainer
var gemGridContainer : GridContainer
@onready var portraitContainer = $CitizenGridContainer

var itemDict : Dictionary = {}

var citGenLabel : Label
var moneyLabel : Label
var energyLabel : Label
var scrapLabel : Label

var itemScene = preload("res://Item Scenes/Item.tscn")
var portraitScene = preload("res://Game Scenes/Citizen Portrait.tscn")

var generatorUI

var citizensGenerated : int = 0

func _ready() -> void:
	
	# i love you signals
	CityManager.storageChanged.connect(updateStorage)
	CityManager.citizenSpawned.connect(onCitizenSpawn)
	
	workArea = $"Work Area"
	citizenGenGrid = $CitizenGenerateGrid
	gemGridContainer = $GemGridContainer
	
	citGenLabel = $GenCitLabel
	
	generatorUI = $"HoloGeneratorDescriptionScene"

	moneyLabel = $HBoxContainer/MoneyLabel
	energyLabel = $HBoxContainer/EnergyLabel
	scrapLabel = $HBoxContainer/ScrapLabel

func _process(_delta: float) -> void:
	# Edit labels and such
	citGenLabel.text = "Generate Citizen \nEnergy: " + str(100 + (citizensGenerated * 10))
	moneyLabel.text = "Money: " + str(CityManager.getCurrentMoney())
	energyLabel.text = "Energy: " + str(CityManager.getCurrentEnergy())
	scrapLabel.text = "Scrap: " + str(CityManager.getCurrentScrap())



func _on_work_area_body_entered(body: Node2D) -> void:
	if body is Citizen:
		if body.currentState == Citizen.State.DELIVERING:
			body.currentState = Citizen.State.IDLE
			body.setWorkDestination()
			body.finishDelivery()

func updateStorage():
	# update our item dict before displaying
	# The item dict tracks the actual item object itself
	for item in CityManager.storage.keys():
		if itemDict.has(item):
			itemDict.get(item).amount = CityManager.storage.get(item)
		else:
			var itemCreated = itemScene.instantiate()
			itemCreated.buildItem(item)
			itemCreated.amount = 1
			if itemCreated.type == Item.Type.GEM:
				gemGridContainer.add_child(itemCreated)
			itemDict[item] = itemCreated

func _on_generate_citizen_button_pressed() -> void:
	# Check cost and all that
	citizensGenerated += 1
	var genScene = load("res://Game Scenes/HoloCitizenGenerationScene.tscn")
	var loadedScene = genScene.instantiate()
	citizenGenGrid.add_child(loadedScene)

func onCitizenSpawn(citizen):
	var portrait = portraitScene.instantiate()
	
	portrait.linkCitizen(citizen)
	
	portraitContainer.add_child(portrait)
