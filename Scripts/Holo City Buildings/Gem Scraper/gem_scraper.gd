extends Control

var minigame : ArrowMinigame

@onready var popupScene = preload("res://Globals/Scene/Popup.tscn")

var workArea
var collisionArea

var fabricatorSprite

var currentWorkers : Array = [] # Make UI to track current workers that the station

var menu

var levelLabel
var workersLabel

var copGemChanceLabel
var quartzGemChanceLabel
var amethystGemChanceLabel
var diamondGemChanceLabel
var galactiteGemChanceLabel

var copperMoneyValueLabel
var copperEnergyValueLabel
var quartzMoneyValueLabel
var quartzEnergyValueLabel
var amethystMoneyValueLabel
var amethystEnergyValueLabel
var diamondMoneyValueLabel
var diamondEnergyValueLabel
var galactiteMoneyValueLabel
var galactiteEnergyValueLabel

var copperAutoSellSwitch : CheckButton
var quartzAutoSellSwitch
var amethystAutoSellSwitch
var diamondAutoSellSwitch
var galactiteAutoSellSwitch

var copperAutoConvertSwitch : CheckButton
var quartzAutoConvertSwitch
var amethystAutoConvertSwitch
var diamondAutoConvertSwitch
var galactiteAutoConvertSwitch

var upgradeButton
var upgradeLabel

var inputTexture1
var inputTexture2
var inputTexture3
var inputTexture4
var inputTexture5

func _ready() -> void:
	workArea = $"Work Area"
	fabricatorSprite = $"Fabricator Sprite"
	menu = $menuControl
	levelLabel = $menuControl/fabricatorMenuBackground/VBoxContainer/levelLabel
	workersLabel = $menuControl/fabricatorMenuBackground/VBoxContainer/currentWorkersLabel
	
	copGemChanceLabel = $menuControl/fabricatorMenuBackground/GemChanceDisplayContainer/copperGemChanceLabel
	quartzGemChanceLabel = $menuControl/fabricatorMenuBackground/GemChanceDisplayContainer/quartzGemChanceLabel
	amethystGemChanceLabel = $menuControl/fabricatorMenuBackground/GemChanceDisplayContainer/amethystGemChanceLabel
	diamondGemChanceLabel = $menuControl/fabricatorMenuBackground/GemChanceDisplayContainer/diamondGemChanceLabel
	galactiteGemChanceLabel= $menuControl/fabricatorMenuBackground/GemChanceDisplayContainer/galactiteGemChanceLabel

	copperMoneyValueLabel = $menuControl/fabricatorMenuBackground/valueContainer/copperValueContainer/moneyValue
	copperEnergyValueLabel =$menuControl/fabricatorMenuBackground/valueContainer/copperValueContainer/energyValue
	quartzMoneyValueLabel =$menuControl/fabricatorMenuBackground/valueContainer/quartzValueContainer/moneyValue
	quartzEnergyValueLabel =$menuControl/fabricatorMenuBackground/valueContainer/quartzValueContainer/energyValue
	amethystMoneyValueLabel =$menuControl/fabricatorMenuBackground/valueContainer/amethystValueContainer/moneyValue
	amethystEnergyValueLabel =$menuControl/fabricatorMenuBackground/valueContainer/amethystValueContainer/energyValue
	diamondMoneyValueLabel =$menuControl/fabricatorMenuBackground/valueContainer/diamondValueContainer/moneyValue
	diamondEnergyValueLabel =$menuControl/fabricatorMenuBackground/valueContainer/diamondValueContainer/energyValue
	galactiteMoneyValueLabel =$menuControl/fabricatorMenuBackground/valueContainer/galactiteValueContainer/moneyValue
	galactiteEnergyValueLabel =$menuControl/fabricatorMenuBackground/valueContainer/galactiteValueContainer/energyValue

	upgradeButton = $menuControl/fabricatorMenuBackground/TextureButton
	upgradeLabel = $menuControl/fabricatorMenuBackground/upgradeScraperLabel
	
	upgradeLabel.text = "Upgrade\n $"+str(CityManager.scraperUpgradeCost)

	copperAutoSellSwitch = $menuControl/fabricatorMenuBackground/autoSellContainer/copperMoneySwitch
	quartzAutoSellSwitch = $menuControl/fabricatorMenuBackground/autoSellContainer/quartzMoneySwitch
	amethystAutoSellSwitch = $menuControl/fabricatorMenuBackground/autoSellContainer/amethystMoneySwitch
	diamondAutoSellSwitch = $menuControl/fabricatorMenuBackground/autoSellContainer/diamondMoneySwitch
	galactiteAutoSellSwitch = $menuControl/fabricatorMenuBackground/autoSellContainer/galactiteMoneySwitch

	copperAutoConvertSwitch = $menuControl/fabricatorMenuBackground/autoConvertContainer/copperConvertSwitch
	quartzAutoConvertSwitch = $menuControl/fabricatorMenuBackground/autoConvertContainer/quartzConvertSwitch
	amethystAutoConvertSwitch = $menuControl/fabricatorMenuBackground/autoConvertContainer/amethystConvertSwitch
	diamondAutoConvertSwitch = $menuControl/fabricatorMenuBackground/autoConvertContainer/diamondConvertSwitch
	galactiteAutoConvertSwitch = $menuControl/fabricatorMenuBackground/autoConvertContainer/galactiteConvertSwitch

	inputTexture1 = $menuControl/fabricatorMenuBackground/VBoxContainer2/HBoxContainer/inputTexture1
	inputTexture2 = $menuControl/fabricatorMenuBackground/VBoxContainer2/HBoxContainer/inputTexture2
	inputTexture3 = $menuControl/fabricatorMenuBackground/VBoxContainer2/HBoxContainer/inputTexture3
	inputTexture4 = $menuControl/fabricatorMenuBackground/VBoxContainer2/HBoxContainer/inputTexture4
	inputTexture5 = $menuControl/fabricatorMenuBackground/VBoxContainer2/HBoxContainer/inputTexture5

	CityManager.storageChanged.connect(refresh)

	minigame = ArrowMinigame.new()
	add_child(minigame)
	minigame.setup([inputTexture1, inputTexture2, inputTexture3, inputTexture4, inputTexture5], 5)
	minigame.success.connect(onMinigameSuccess)


func refresh():
	if menu.visible:
		var labelList = [copperMoneyValueLabel,quartzMoneyValueLabel,amethystMoneyValueLabel,diamondMoneyValueLabel,galactiteMoneyValueLabel]
		for i in range(5):
			labelList[i].text = "$" + str(int(CityManager.itemMoneyValueDict.get(CityManager.gemChances.keys()[i])))
		
		#setup energy value
		labelList = [copperEnergyValueLabel,quartzEnergyValueLabel,amethystEnergyValueLabel,diamondEnergyValueLabel,galactiteEnergyValueLabel]
		for i in range(5):
			labelList[i].text = str(float(CityManager.itemEnergyValueDict.get(CityManager.gemChances.keys()[i])))

func _on_work_area_body_entered(body: Node2D) -> void:
	if body is Citizen:
		if not body.hasJob:
			body.setJob(Citizen.Job.GEM_SCRAPER)
		else:
			if body.currentState != Citizen.State.WORKING and body.currentJob == Citizen.Job.GEM_SCRAPER:
				body.currentState = Citizen.State.WORKING

func buildMenu():
	levelLabel.text = "Level: " + str(CityManager.gemScraperLevel)
	var workerAmount = 0
	for cit : Citizen in CityManager.citizens:
		if cit.currentJob == cit.Job.GEM_SCRAPER:
			workerAmount += 1
	workersLabel.text = "Workers: " + str(workerAmount)
	# manually adding cus idc im not doing it dynamically
	var labelList = [copGemChanceLabel,quartzGemChanceLabel,amethystGemChanceLabel,diamondGemChanceLabel,galactiteGemChanceLabel]
	
	for i in range(5):
		labelList[i].text = str(CityManager.gemChances[i]) + "%"
	
	#setup money value
	labelList = [copperMoneyValueLabel,quartzMoneyValueLabel,amethystMoneyValueLabel,diamondMoneyValueLabel,galactiteMoneyValueLabel]
	for i in range(5):
		labelList[i].text = "$" + str(int(CityManager.itemMoneyValueDict.get(CityManager.gemChances.keys()[i])))
	
	#setup energy value
	labelList = [copperEnergyValueLabel,quartzEnergyValueLabel,amethystEnergyValueLabel,diamondEnergyValueLabel,galactiteEnergyValueLabel]
	for i in range(5):
		labelList[i].text = str(float(CityManager.itemEnergyValueDict.get(CityManager.gemChances.keys()[i])))


func _on_select_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var clickPos = get_global_mouse_position()
			var allCitizens = get_tree().get_nodes_in_group("Citizen")
			for citizen in allCitizens:
				if citizen is Citizen and citizen.global_position.distance_to(clickPos) < 30:
					return
			menu.show()
			buildMenu()
			await get_tree().process_frame  # wait one frame
			minigame.start()


func _on_copper_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertCommonGem = false
		copperAutoConvertSwitch.button_pressed = false
		CityManager.autoSellCommonGem = true
		CityManager.massAutoSell(Item.theItem.COPPER_GEM)
	else:
		CityManager.autoSellCommonGem = false


func _on_quartz_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertRareGem = false
		quartzAutoConvertSwitch.button_pressed = false
		CityManager.autoSellRareGem = true
		CityManager.massAutoSell(Item.theItem.QUARTZ_GEM)
	else:
		CityManager.autoSellRareGem = false


func _on_amethyst_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertSuperRareGem = false
		amethystAutoConvertSwitch.button_pressed = false
		CityManager.autoSellSuperRareGem = true
		CityManager.massAutoSell(Item.theItem.AMETHYST_GEM)
	else:
		CityManager.autoSellSuperRareGem = false


func _on_diamond_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertLegendaryGem = false
		diamondAutoConvertSwitch.button_pressed = false
		CityManager.autoSellLegendaryGem = true
		CityManager.massAutoSell(Item.theItem.DIAMOND_GEM)
	else:
		CityManager.autoSellLegendaryGem = false


func _on_galactite_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertUnseenGem = false
		galactiteAutoConvertSwitch.button_pressed = false
		CityManager.autoSellUnseenGem = true
		CityManager.massAutoSell(Item.theItem.GALACTITE_GEM)
	else:
		CityManager.autoSellUnseenGem = false


func _on_copper_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellCommonGem = false
		copperAutoSellSwitch.button_pressed = false
		CityManager.autoConvertCommonGem = true
		CityManager.massAutoConvert(Item.theItem.COPPER_GEM)
	else:
		CityManager.autoConvertCommonGem = false


func _on_quartz_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellRareGem = false
		quartzAutoSellSwitch.button_pressed = false
		CityManager.autoConvertRareGem = true
		CityManager.massAutoConvert(Item.theItem.QUARTZ_GEM)
	else:
		CityManager.autoConvertRareGem = false


func _on_amethyst_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellSuperRareGem = false
		amethystAutoSellSwitch.button_pressed = false
		CityManager.autoConvertSuperRareGem = true
		CityManager.massAutoConvert(Item.theItem.AMETHYST_GEM)
	else:
		CityManager.autoConvertSuperRareGem = false


func _on_diamond_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellLegendaryGem = false
		diamondAutoSellSwitch.button_pressed = false
		CityManager.autoConvertLegendaryGem= true
		CityManager.massAutoConvert(Item.theItem.DIAMOND_GEM)
	else:
		CityManager.autoConvertLegendaryGem = false


func _on_galactite_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellUnseenGem = false
		galactiteAutoSellSwitch.button_pressed = false
		CityManager.autoConvertUnseenGem = true
		CityManager.massAutoConvert(Item.theItem.GALACTITE_GEM)
	else:
		CityManager.autoConvertUnseenGem = false


func _on_texture_button_mouse_entered() -> void:
	var labelList = [copGemChanceLabel,quartzGemChanceLabel,amethystGemChanceLabel,diamondGemChanceLabel,galactiteGemChanceLabel]
	
	var chances = CityManager.calcGemChanceWeights(CityManager.gemScraperLevel+1)
	
	levelLabel.text = "Level: " + str(CityManager.gemScraperLevel + 1)
	levelLabel.add_theme_color_override("font_color", Color.GREEN)
	
	for i in range(5):
		labelList[i].add_theme_color_override("font_color", Color.GREEN)
		labelList[i].text = str(chances[i]) + "%"


func _on_texture_button_mouse_exited() -> void:
	levelLabel.text = "Level: " + str(CityManager.gemScraperLevel)
	levelLabel.add_theme_color_override("font_color", Color.WHITE)
	
	var labelList = [copGemChanceLabel,quartzGemChanceLabel,amethystGemChanceLabel,diamondGemChanceLabel,galactiteGemChanceLabel]
	
	for i in range(5):
		labelList[i].add_theme_color_override("font_color", Color.WHITE)
		labelList[i].text = str(CityManager.gemChances[i]) + "%"


func _on_texture_button_pressed() -> void:
	if CityManager.currentMoney >= CityManager.scraperUpgradeCost:
		CityManager.currentMoney -= CityManager.scraperUpgradeCost
		CityManager.addCityXp("purchase_upgrade")
		CityManager.gemScraperLevel += 1
		CityManager.updateScraperUpgradeCost()
		levelLabel.text = "Level: " + str(CityManager.gemScraperLevel)
		CityManager.updateGemChanceWeights()
		var labelList = [copGemChanceLabel,quartzGemChanceLabel,amethystGemChanceLabel,diamondGemChanceLabel,galactiteGemChanceLabel]
		for i in range(5):
			labelList[i].text = str(CityManager.gemChances[i]) + "%"
			
		upgradeLabel.text = "Upgrade\n $"+str(CityManager.scraperUpgradeCost)
		_on_texture_button_mouse_entered()
	
	if CityManager.gemScraperLevel >= CityManager.maxScraperLevel:
		upgradeButton.queue_free()
		upgradeLabel.queue_free()


func onMinigameSuccess() -> void:
	rollGem()  # or whatever this building's reward is
	SoundManager.playManualGenSound(2)
	await get_tree().create_timer(0.35).timeout
	minigame.start()

func rollGem():
	var gemKeys = [
		Item.theItem.COPPER_GEM,
		Item.theItem.QUARTZ_GEM,
		Item.theItem.AMETHYST_GEM,
		Item.theItem.DIAMOND_GEM,
		Item.theItem.GALACTITE_GEM
	]
	
	var gemNames = ["Copper", "Quartz", "Amethyst", "Diamond", "Galactite"]
	
	var roll = randf_range(0.0, 100.0)
	var cumulativeWeight = 0.0
	var selectedGem = null

	# Create a fresh top-level CanvasLayer that renders above everything
	var topLayer = CanvasLayer.new()
	topLayer.layer = 100          # higher than any UI in your game
	get_tree().current_scene.add_child(topLayer)

	var popup = popupScene.instantiate()
	topLayer.add_child(popup)
	#popup.setPosition(get_viewport_rect().size / 2)
	popup.setPosition(CityManager.getGemScraperLocation())
	popup.scale = Vector2(9,9)
	#popup.global_position.y -= 300
	popup.global_position.x += 35

	for i in range(gemKeys.size()):
		var gemKey = gemKeys[i]
		cumulativeWeight += CityManager.gemChances[gemKey]
		if roll <= cumulativeWeight:
			selectedGem = gemKey
			popup.gemPopup(gemNames[i])
			CityManager.addItem(selectedGem)
			break

	# Clean up the layer after the popup is done
	await get_tree().create_timer(2.0).timeout
	topLayer.queue_free()


func _on_menu_control_visibility_changed() -> void:
	if menu.visible:
		CityManager.currentPopup = menu
	else:
		if CityManager.currentPopup == menu:
			CityManager.currentPopup = null
		minigame.stop()
