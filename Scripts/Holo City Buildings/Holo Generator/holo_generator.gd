extends Control

var workArea
var collisionArea


var citizenGenGrid : GridContainer
var gemGridContainer : GridContainer
var materialGridContainer : GridContainer
# Needs to be prio loaded in case citizen spawns before generator when loading game
@onready var portraitContainer = $CitizenGridContainer
@onready var resourceTimer : Timer = $GenerateResourcesTimer
@onready var resourceBar = $ResourceGenerationBar

var itemDict : Dictionary = {}

var citGenLabel : Label
var upgradeGenLabel : Label
var moneyLabel : Label
var energyLabel : Label
var scrapLabel : Label

var generatorLevelLabel : RichTextLabel
var moneyGenLabel : RichTextLabel
var energyGenLabel : RichTextLabel
var scrapGenLabel : RichTextLabel

var itemScene = preload("res://Item Scenes/Item.tscn")
var portraitScene = preload("res://Game Scenes/Citizen Portrait.tscn")

var citizensGenerated : int = 0

func _ready() -> void:
	
	# i love you signals
	CityManager.storageChanged.connect(updateStorage)
	CityManager.citizenSpawned.connect(onCitizenSpawn)

	resourceTimer.wait_time = 8
	
	resourceBar.max_value = resourceTimer.wait_time
	
	generatorLevelLabel = $GeneratorLevelLabel
	
	moneyGenLabel = $HBoxContainer2/moneyGenLabel
	energyGenLabel = $HBoxContainer2/energyGenLabel
	scrapGenLabel = $HBoxContainer2/scrapGenLabel
	
	workArea = $"Work Area"
	citizenGenGrid = $CitizenGenerateGrid
	gemGridContainer = $GemGridContainer
	materialGridContainer = $MaterialGridContainer
	
	resourceBar = $ResourceGenerationBar
	
	citGenLabel = $GenCitLabel
	
	moneyLabel = $HBoxContainer/MoneyLabel
	energyLabel = $HBoxContainer/EnergyLabel
	scrapLabel = $HBoxContainer/ScrapLabel
	upgradeGenLabel = $UpgradeGenLabel
	
	moneyGenLabel.text = "Money Gen: " + str(CityManager.moneyGenerated)
	energyGenLabel.text = "Energy Gen: " + str(CityManager.energyGenerated)
	scrapGenLabel.text = "Scrap Gen: " + str(CityManager.scrapGenerated) 

func _process(_delta: float) -> void:
	# Edit labels and such
	resourceBar.value = resourceTimer.wait_time - resourceTimer.time_left
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
			if is_instance_valid(itemDict.get(item)):
				itemDict.get(item).amount = CityManager.storage.get(item)
			else:
				itemDict.erase(item)
				updateStorage() # recursive call after removing the freed item because im a genius...jk ik checking instance valid is bleh but idc
				return
		else:
			if CityManager.storage.get(item) > 0: # Keeps the recursion from duplicating items
				var itemCreated = itemScene.instantiate()
				itemCreated.buildItem(item)
				itemCreated.amount = 1
				if itemCreated.type == Item.Type.GEM:
					gemGridContainer.add_child(itemCreated)
				if itemCreated.type == Item.Type.MATERIAL:
					materialGridContainer.add_child(itemCreated)
				itemDict[item] = itemCreated

func _on_generate_citizen_button_pressed() -> void:
	# Check cost and all that
	citGenLabel.text = "Generate Citizen \nEnergy: " + str(100 + (citizensGenerated * 10))
	citizensGenerated += 1
	var genScene = load("res://Game Scenes/HoloCitizenGenerationScene.tscn")
	var loadedScene = genScene.instantiate()
	citizenGenGrid.add_child(loadedScene)

func onCitizenSpawn(citizen):
	var portrait = portraitScene.instantiate()
	
	portrait.linkCitizen(citizen)
	
	portraitContainer.add_child(portrait)


func _on_upgrade_generator_button_pressed() -> void:
	# Check cost and all that
	CityManager.upgradeGenerator()
	upgradeGenLabel.text = "Upgrade\n Generator \nEnergy: " + str(100 + (CityManager.generatorLevel * 10))
	moneyGenLabel.text = "Money Gen: " + str(CityManager.moneyGenerated)
	energyGenLabel.text = "Energy Gen: " + str(CityManager.energyGenerated)
	scrapGenLabel.text = "Scrap Gen: " + str(CityManager.scrapGenerated) 
	generatorLevelLabel.text = "Generator Level: " + str(CityManager.generatorLevel)
	_on_upgrade_generator_button_mouse_entered()
	
	if CityManager.generatorLevel >= 50:
		$UpgradeGeneratorButton.queue_free()
		$UpgradeGenLabel.queue_free()

func _on_generate_resources_timer_timeout() -> void:
	CityManager.generateResources()


func _on_upgrade_generator_button_mouse_entered() -> void:
	moneyGenLabel.text = "Money Gen: [color=green]" + str(CityManager.moneyGenerated + ceil(1*(pow(1.10,((CityManager.generatorLevel+1)-1))))) + "[/color]"
	energyGenLabel.text = "Energy Gen: [color=green]" + str(CityManager.energyGenerated + round((1*(pow(1.07,((CityManager.generatorLevel+1)-1))))*100) / 100) + "[/color]"
	scrapGenLabel.text = "Scrap Gen: [color=green]" + str(CityManager.scrapGenerated + ceil(1*(pow(1.08,((CityManager.generatorLevel+1)-1))))) + "[/color]"
	generatorLevelLabel.text = "Generator Level: [color=green]" + str(CityManager.generatorLevel + 1) + "[/color]"


func _on_upgrade_generator_button_mouse_exited() -> void:
	moneyGenLabel.text = "Money Gen: " + str(CityManager.moneyGenerated)
	energyGenLabel.text = "Energy Gen: " + str(CityManager.energyGenerated)
	scrapGenLabel.text = "Scrap Gen: " + str(CityManager.scrapGenerated)
	generatorLevelLabel.text = "Generator Level: " + str(CityManager.generatorLevel)
