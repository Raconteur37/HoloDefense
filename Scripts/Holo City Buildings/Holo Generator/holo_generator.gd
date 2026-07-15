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
var moneyLabel : RichTextLabel
var energyLabel : RichTextLabel
var scrapLabel : RichTextLabel

var generatorLevelLabel : RichTextLabel
var moneyGenLabel : RichTextLabel
var energyGenLabel : RichTextLabel
var scrapGenLabel : RichTextLabel

var cityLevelLabel : Label

var citNameLabel : Label
var citAtomizerProgressBar : TextureProgressBar
var citGemScraperProgressBar : TextureProgressBar
var citResearchProgressBar : TextureProgressBar
var citFabricatorProgressBar : TextureProgressBar
var citPortrait : TextureRect
var citCurrentJobLabel : RichTextLabel
var workProgressBar : TextureProgressBar

var integrityLabel : RichTextLabel

var difficultyLabel
var systemLabel
var waveLabel
var intermissionLabel

var singleCitUI

var itemScene = preload("res://Item Scenes/Item.tscn")
var portraitScene = preload("res://Game Scenes/Citizen Portrait.tscn")

var citizensGenerated : int = 0

var singleCitUIShown = false

var materialAbstract
var glowShader


func _ready() -> void:
	
	# i love you signals
	CityManager.storageChanged.connect(updateStorage)
	CityManager.citizenSpawned.connect(onCitizenSpawn)

	resourceTimer.wait_time = 8
	
	resourceBar.max_value = resourceTimer.wait_time
	
	generatorLevelLabel = $GeneratorLevelLabel
	
	moneyGenLabel = $VBoxContainer/moneyGenLabel
	energyGenLabel = $VBoxContainer/energyGenLabel
	scrapGenLabel = $VBoxContainer/scrapGenLabel
	
	workArea = $"Work Area"
	citizenGenGrid = $CitizenGenerateGrid
	gemGridContainer = $GemGridContainer
	materialGridContainer = $MaterialGridContainer
	
	resourceBar = $ResourceGenerationBar
	
	citGenLabel = $GenCitLabel
	
	moneyLabel = $MoneyRichLabel
	energyLabel = $EnergyRichLabel
	scrapLabel = $ScrapRichLabel
	upgradeGenLabel = $UpgradeGenLabel
	
	cityLevelLabel = $cityLevelLabel
	
	citNameLabel = $SingleCitUI/Name
	citAtomizerProgressBar = $SingleCitUI/Panel/AtomizerProgressBar
	citGemScraperProgressBar = $SingleCitUI/Panel2/GemScraperProgressBar
	citResearchProgressBar = $SingleCitUI/Panel3/ResearchProgressBar
	citFabricatorProgressBar = $SingleCitUI/Panel4/FabricatorProgressBar
	citCurrentJobLabel = $SingleCitUI/currentJobLabel
	citPortrait = $SingleCitUI/portrait
	workProgressBar = $SingleCitUI/workProgressBar
	
	singleCitUI = $SingleCitUI
	
	integrityLabel = $IntegrityLabel
	
	difficultyLabel = $WaveData/DifficultyLabel
	systemLabel = $WaveData/SystemLabel
	waveLabel = $WaveData/WaveLabel
	intermissionLabel = $WaveData/IntermissionLabel
	
	materialAbstract = ShaderMaterial.new()
	glowShader = load("res://Shaders/pulsing_glow.gdshader")
	
	upgradeGenLabel.text = "Upgrade\n Generator\n $" + str(GameManager.format_number(CityManager.generatorUpgradeCost))
	moneyGenLabel.text = "[img]res://Textures/Icons/icon_moneybag.png[/img] Generated: " + str(GameManager.format_number(CityManager.moneyGenerated))
	energyGenLabel.text = "[img]res://Textures/Icons/icon_bolt_final.png[/img] Generated: " + str(GameManager.format_number(GameManager.round_to_dec(CityManager.energyGenerated,2)))
	scrapGenLabel.text = "[img]res://Textures/Citizens/Scrap/Common Scrap.png[/img] Generated: " + str(GameManager.format_number(CityManager.scrapGenerated)) 
	
	citGenLabel.text = "Generate Citizen \nEnergy: " + str(CityManager.citizenGenCost)


func _process(_delta: float) -> void:
	# Edit labels and such
	resourceBar.value = resourceTimer.wait_time - resourceTimer.time_left
	moneyLabel.text = "[img=48x48]res://Textures/Icons/icon_moneybag.png[/img]  " + str(GameManager.format_number(CityManager.getCurrentMoney()))
	energyLabel.text = "[img=48x48]res://Textures/Icons/icon_bolt_final.png[/img]  " + str(GameManager.format_number(GameManager.round_to_dec(CityManager.getCurrentEnergy(),2)))
	scrapLabel.text = "[img=48x48]res://Textures/Citizens/Scrap/Common Scrap.png[/img]  " + str(GameManager.format_number(CityManager.getCurrentScrap()))
	cityLevelLabel.text = "Ctiy Level: " + str(CityManager.cityLevel)
	integrityLabel.text = "[pulse color=pink height=0.5 freq=0.1][font_size=26]City Integrity: " + str(GameManager.cityHealth) + "[/font_size][/pulse]"
	
	
	
	if CityManager.citizensSelected.size() < 2 && CityManager.citizensSelected.size() > 0 && !singleCitUIShown:
		singleCitUIShown = true
		refreshSingelCitUI()
		singleCitUI.show()
		portraitContainer.hide()
	if singleCitUIShown && CityManager.citizensSelected.size() == 0:
		singleCitUIShown = false
		singleCitUI.hide()
		portraitContainer.show()
	if singleCitUIShown:
		refreshSingelCitUI()


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
	if CityManager.currentEnergy >= CityManager.citizenGenCost:
		CityManager.addCityXp("spawn_citizen")
		CityManager.citizensGenerated += 1
		CityManager.currentEnergy -= CityManager.citizenGenCost
		CityManager.updateGenCitizenCost()
		StatManager.citizensGenerated += 1
		if StatManager.citizensGenerated >= 60:
			AchievementManager.unlock_achievement("ACH_MASS_TURRETS_PLACED")
		citGenLabel.text = "Generate Citizen \nEnergy: " + str(GameManager.format_number(round((round(100 * CityManager.citizenGenCost)/100))))
		var genScene = load("res://Game Scenes/HoloCitizenGenerationScene.tscn")
		var loadedScene = genScene.instantiate()
		citizenGenGrid.add_child(loadedScene)

func onCitizenSpawn(citizen):
	var portrait = portraitScene.instantiate()
	
	portraitContainer.add_child(portrait)
	
	portrait.linkCitizen(citizen,false)
	
	citizen.citPortrait = portrait



func _on_upgrade_generator_button_pressed() -> void:
	if CityManager.currentMoney >= CityManager.generatorUpgradeCost:
		CityManager.currentMoney -= CityManager.generatorUpgradeCost
		CityManager.addCityXp("purchase_upgrade")
		CityManager.upgradeGenerator()
		upgradeGenLabel.text = "Upgrade\n Generator \n$" + str(GameManager.format_number(CityManager.generatorUpgradeCost))
		moneyGenLabel.text = "Money Gen: " + str(GameManager.format_number(CityManager.moneyGenerated))
		energyGenLabel.text = "Energy Gen: " + str(GameManager.format_number(CityManager.energyGenerated))
		scrapGenLabel.text = "Scrap Gen: " + str(GameManager.format_number(CityManager.scrapGenerated)) 
		generatorLevelLabel.text = "[pulse color=aqua height=0.5 freq=0.5][font_size=26]Generator Level: " + str(CityManager.generatorLevel) + "[/font_size][/pulse]" 
		_on_upgrade_generator_button_mouse_entered()
		
		if CityManager.generatorLevel >= 50:
			$UpgradeGeneratorButton.queue_free()
			$UpgradeGenLabel.queue_free()

func _on_generate_resources_timer_timeout() -> void:
	CityManager.generateResources()


func _on_upgrade_generator_button_mouse_entered() -> void:
	moneyGenLabel.text = "[img]res://Textures/Icons/icon_moneybag.png[/img] Generated: " + str(CityManager.moneyGenerated) + "[pulse color=lime height=0.5 freq=.8]  ->  " + str(CityManager.moneyGenerated + ceil(1*(pow(CityManager.moneyScale,((CityManager.generatorLevel+1)-1))))) + "[/pulse]"
	energyGenLabel.text = "[img]res://Textures/Icons/icon_bolt_final.png[/img] Generated: " + str(CityManager.energyGenerated) + "[pulse color=lime height=0.5 freq=.8]  ->  " + str(CityManager.energyGenerated +  round((1*(pow(CityManager.energyScale,((CityManager.generatorLevel+1)-1))))*100) / 100) + "[/pulse]"
	scrapGenLabel.text = "[img]res://Textures/Citizens/Scrap/Common Scrap.png[/img] Generated: " + str(CityManager.scrapGenerated) + "[pulse color=lime height=0.5 freq=.8]  ->  " + str(CityManager.scrapGenerated + ceil(1*(pow(CityManager.scrapScale,((CityManager.generatorLevel+1)-1))))) + "[/pulse]"
	generatorLevelLabel.text = "[pulse color=lime height=0.5 freq=0.8][font_size=26]Generator Level: " + str(CityManager.generatorLevel + 1) + "[/font_size][/pulse]" 


func _on_upgrade_generator_button_mouse_exited() -> void:
	moneyGenLabel.text = "[img]res://Textures/Icons/icon_moneybag.png[/img] Generated: " + str(CityManager.moneyGenerated)
	energyGenLabel.text = "[img]res://Textures/Icons/icon_bolt_final.png[/img] Generated: " + str(CityManager.energyGenerated)
	scrapGenLabel.text = "[img]res://Textures/Citizens/Scrap/Common Scrap.png[/img] Generated: " + str(CityManager.scrapGenerated) 
	generatorLevelLabel.text = "[pulse color=aqua height=0.5 freq=0.5][font_size=26]Generator Level: " + str(CityManager.generatorLevel) + "[/font_size][/pulse]" 

func refreshSingelCitUI():
	var citizen : Citizen = CityManager.citizensSelected[0]
	citNameLabel.text = citizen.citName
	
	citAtomizerProgressBar.max_value = CitizenManager.maxCitizenJobLevel
	citGemScraperProgressBar.max_value = CitizenManager.maxCitizenJobLevel
	citResearchProgressBar.max_value = CitizenManager.maxCitizenJobLevel
	citFabricatorProgressBar.max_value = CitizenManager.maxCitizenJobLevel
	
	citAtomizerProgressBar.value = citizen.jobExperience.get(Citizen.Job.MATERIAL_ATOMIZER)
	citGemScraperProgressBar.value = citizen.jobExperience.get(Citizen.Job.GEM_SCRAPER)
	citResearchProgressBar.value = citizen.jobExperience.get(Citizen.Job.RESEARCHER)
	citFabricatorProgressBar.value = citizen.jobExperience.get(Citizen.Job.FABRICATOR)
	
	citGemScraperProgressBar.get_parent().material = null
	citAtomizerProgressBar.get_parent().material = null
	citResearchProgressBar.get_parent().material = null
	citFabricatorProgressBar.get_parent().material = null
	workProgressBar.value = 0
	
	# Portrait photo
	citPortrait.texture = load(citizen.characterPortrait)
	materialAbstract.shader = glowShader
	match citizen.currentJob:
		
		Citizen.Job.NONE:
			citCurrentJobLabel.text = "Current Job: None"
		Citizen.Job.GEM_SCRAPER:
			citCurrentJobLabel.text = "Current Job: Gem Scraper"
			citGemScraperProgressBar.get_parent().material = materialAbstract
			var elapsed_time = citizen.workTimer.wait_time - citizen.workTimer.time_left
			workProgressBar.max_value = citizen.workTimer.wait_time
			workProgressBar.value = elapsed_time
		Citizen.Job.MATERIAL_ATOMIZER:
			citCurrentJobLabel.text = "Current Job: Material Atomizer"
			citAtomizerProgressBar.get_parent().material = materialAbstract
			var elapsed_time = citizen.workTimer.wait_time - citizen.workTimer.time_left
			workProgressBar.max_value = citizen.workTimer.wait_time
			workProgressBar.value = elapsed_time
		Citizen.Job.RESEARCHER:
			citCurrentJobLabel.text = "Current Job: Researcher"
			citResearchProgressBar.get_parent().material = materialAbstract
		Citizen.Job.FABRICATOR:
			citCurrentJobLabel.text = "Current Job: Fabricator"
			citFabricatorProgressBar.get_parent().material = materialAbstract
