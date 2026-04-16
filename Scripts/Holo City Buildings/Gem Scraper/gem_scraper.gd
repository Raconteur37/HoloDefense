extends Control

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

var upgradeButton

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
			menu.show()


func _on_popup_visibility_changed() -> void:
	if menu.visible:
		buildMenu()


func _on_copper_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellCommonGem = true
		CityManager.massAutoSell(Item.theItem.COPPER_GEM)
	else:
		CityManager.autoSellCommonGem = false


func _on_quartz_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellRareGem = true
		CityManager.massAutoSell(Item.theItem.QUARTZ_GEM)
	else:
		CityManager.autoSellRareGem = false


func _on_amethyst_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellSuperRareGem = true
		CityManager.massAutoSell(Item.theItem.AMETHYST_GEM)
	else:
		CityManager.autoSellSuperRareGem = false


func _on_diamond_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellLegendaryGem = true
		CityManager.massAutoSell(Item.theItem.DIAMOND_GEM)
	else:
		CityManager.autoSellLegendaryGem = false


func _on_galactite_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellUnseenGem = true
		CityManager.massAutoSell(Item.theItem.GALACTITE_GEM)
	else:
		CityManager.autoSellUnseenGem = false


func _on_copper_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertCommonGem = true
		CityManager.massAutoConvert(Item.theItem.COPPER_GEM)
	else:
		CityManager.autoConvertCommonGem = false


func _on_quartz_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertRareGem = true
		CityManager.massAutoConvert(Item.theItem.QUARTZ_GEM)
	else:
		CityManager.autoConvertRareGem = false


func _on_amethyst_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertSuperRareGem = true
		CityManager.massAutoConvert(Item.theItem.AMETHYST_GEM)
	else:
		CityManager.autoConvertSuperRareGem = false


func _on_diamond_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertLegendaryGem= true
		CityManager.massAutoConvert(Item.theItem.DIAMOND_GEM)
	else:
		CityManager.autoConvertLegendaryGem = false


func _on_galactite_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
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
	CityManager.gemScraperLevel += 1
	levelLabel.text = "Level: " + str(CityManager.gemScraperLevel)
	CityManager.updateGemChanceWeights()
	var labelList = [copGemChanceLabel,quartzGemChanceLabel,amethystGemChanceLabel,diamondGemChanceLabel,galactiteGemChanceLabel]
	for i in range(5):
		labelList[i].text = str(CityManager.gemChances[i]) + "%"
	_on_texture_button_mouse_entered()
	
	if CityManager.gemScraperLevel >= CityManager.maxScraperLevel:
		$menuControl/fabricatorMenuBackground/TextureButton.queue_free()
		$menuControl/fabricatorMenuBackground/upgradeScraperLabel.queue_free()
