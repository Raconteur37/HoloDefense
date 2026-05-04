extends Control

var workArea
var collisionArea

var atomizerSprite

var atomizerMenu

var titleLabel
var levelLabel
var currentWorkersLabel

var commonChanceLabel
var rareChanceLabel
var superRareChanceLabel
var legendaryChanceLabel
var unseenChanceLabel

var commonMoneyValue
var rareMoneyValue
var superRareMoneyValue
var legendaryMoneyValue
var unseenMoneyValue

var commonScrapValue
var rareScrapValue
var superRareScrapValue
var legendaryScrapValue
var unseenScrapValue

var upgradeButton
var upgradeLabel

func _ready() -> void:
	workArea = $"Work Area"
	atomizerSprite = $BuildSprite
	atomizerMenu = $menuControl
	
	titleLabel = $menuControl/AtomizerMenuBackground/VBoxContainer/titleLabel
	levelLabel = $menuControl/AtomizerMenuBackground/VBoxContainer/levelLabel
	currentWorkersLabel = $menuControl/AtomizerMenuBackground/VBoxContainer/currentWorkersLabel
	
	commonChanceLabel = $menuControl/AtomizerMenuBackground/ScrapChanceDisplayContainer/commonChanceLabel
	rareChanceLabel = $menuControl/AtomizerMenuBackground/ScrapChanceDisplayContainer/rareChanceLabel
	superRareChanceLabel = $menuControl/AtomizerMenuBackground/ScrapChanceDisplayContainer/superRareGemChanceLabel
	legendaryChanceLabel = $menuControl/AtomizerMenuBackground/ScrapChanceDisplayContainer/legendaryGemChanceLabel
	unseenChanceLabel = $menuControl/AtomizerMenuBackground/ScrapChanceDisplayContainer/unseenGemChanceLabel

	commonMoneyValue = $menuControl/AtomizerMenuBackground/valueContainer/commonValueContainer/moneyValue
	rareMoneyValue = $menuControl/AtomizerMenuBackground/valueContainer/rareValueContainer/moneyValue
	superRareMoneyValue = $menuControl/AtomizerMenuBackground/valueContainer/superRareValueContainer/moneyValue
	legendaryMoneyValue = $menuControl/AtomizerMenuBackground/valueContainer/legendaryValueContainer/moneyValue
	unseenMoneyValue = $menuControl/AtomizerMenuBackground/valueContainer/unseenValueContainer/moneyValue

	commonScrapValue = $menuControl/AtomizerMenuBackground/valueContainer/commonValueContainer/scrapValue
	rareScrapValue = $menuControl/AtomizerMenuBackground/valueContainer/rareValueContainer/scrapValue
	superRareScrapValue = $menuControl/AtomizerMenuBackground/valueContainer/superRareValueContainer/scrapValue
	legendaryScrapValue = $menuControl/AtomizerMenuBackground/valueContainer/legendaryValueContainer/scrapValue
	unseenScrapValue = $menuControl/AtomizerMenuBackground/valueContainer/unseenValueContainer/scrapValue

	upgradeButton = $menuControl/AtomizerMenuBackground/TextureButton
	upgradeLabel = $menuControl/AtomizerMenuBackground/upgradeAtomizerLabel
	
	upgradeLabel.text = "Upgrade\n $" + str(CityManager.atomizerUpgradeCost)
	
	CityManager.storageChanged.connect(refresh)

func refresh():
	if atomizerMenu.visible:
		var labelList = [commonMoneyValue,rareMoneyValue,superRareMoneyValue,legendaryMoneyValue,unseenMoneyValue]
		for i in range(5):
			labelList[i].text = "$" + str(int(CityManager.itemMoneyValueDict.get(CityManager.scrapChances.keys()[i])))
		
		#setup scrap value
		labelList = [commonScrapValue,rareScrapValue,superRareScrapValue,legendaryScrapValue,unseenScrapValue]
		for i in range(5):
			labelList[i].text = str(int(CityManager.itemScrapValueDict.get(CityManager.scrapChances.keys()[i])))

func buildMenu():
	levelLabel.text = "Level: " + str(CityManager.materialAtomizerLevel)
	var workerAmount = 0
	for cit : Citizen in CityManager.citizens:
		if cit.currentJob == cit.Job.MATERIAL_ATOMIZER:
			workerAmount += 1
	currentWorkersLabel.text = "Workers: " + str(workerAmount)
	
	var labelList = [commonChanceLabel,rareChanceLabel,superRareChanceLabel,legendaryChanceLabel,unseenChanceLabel]
	for i in range(5):
		labelList[i].text = str(CityManager.scrapChances.values()[i]) + "%"

	#setup money value
	labelList = [commonMoneyValue,rareMoneyValue,superRareMoneyValue,legendaryMoneyValue,unseenMoneyValue]
	for i in range(5):
		labelList[i].text = "$" + str(int(CityManager.itemMoneyValueDict.get(CityManager.scrapChances.keys()[i])))
	
	#setup scrap value
	labelList = [commonScrapValue,rareScrapValue,superRareScrapValue,legendaryScrapValue,unseenScrapValue]
	for i in range(5):
		labelList[i].text = str(int(CityManager.itemScrapValueDict.get(CityManager.scrapChances.keys()[i])))

func _on_work_area_body_entered(body: Node2D) -> void:
	if body is Citizen:
		if not body.hasJob:
			body.setJob(Citizen.Job.MATERIAL_ATOMIZER)
		else:
			if body.currentState != Citizen.State.WORKING and body.currentJob == Citizen.Job.MATERIAL_ATOMIZER:
				body.currentState = Citizen.State.WORKING


func _on_select_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			atomizerMenu.show()


func _on_menu_control_visibility_changed() -> void:
	if atomizerMenu.visible:
		buildMenu()


func _on_texture_button_pressed() -> void:
	if CityManager.currentMoney >= CityManager.atomizerUpgradeCost:
		CityManager.currentMoney -= CityManager.atomizerUpgradeCost
		CityManager.addCityXp("purchase_upgrade")
		CityManager.materialAtomizerLevel += 1
		levelLabel.text = "Level: " + str(CityManager.materialAtomizerLevel)
		CityManager.updateAtomizerUpgradeCost()
		CityManager.updateScrapChanceWeights()
		upgradeLabel.text = "Upgrade\n $" + str(CityManager.atomizerUpgradeCost)
		var labelList = [commonChanceLabel,rareChanceLabel,superRareChanceLabel,legendaryChanceLabel,unseenChanceLabel]
		for i in range(5):
			labelList[i].text = str(CityManager.scrapChances.values()[i]) + "%"
		_on_texture_button_mouse_entered()
		
		if CityManager.materialAtomizerLevel >= CityManager.maxAtomizerLevel:
			upgradeButton.queue_free()
			upgradeLabel.queue_free()


func _on_texture_button_mouse_entered() -> void:
	var labelList = [commonChanceLabel,rareChanceLabel,superRareChanceLabel,legendaryChanceLabel,unseenChanceLabel]

	var chances = CityManager.calcAtomizerChanceWeights(CityManager.materialAtomizerLevel+1)
	
	levelLabel.text = "Level: " + str(CityManager.materialAtomizerLevel + 1)
	levelLabel.add_theme_color_override("font_color", Color.GREEN)
	
	
	for i in range(5):
		labelList[i].add_theme_color_override("font_color", Color.GREEN)
		labelList[i].text = str(chances.values()[i]) + "%"


func _on_texture_button_mouse_exited() -> void:
	levelLabel.text = "Level: " + str(CityManager.materialAtomizerLevel)
	levelLabel.add_theme_color_override("font_color", Color.WHITE)
	
	var labelList = [commonChanceLabel,rareChanceLabel,superRareChanceLabel,legendaryChanceLabel,unseenChanceLabel]
	
	for i in range(5):
		labelList[i].add_theme_color_override("font_color", Color.WHITE)
		labelList[i].text = str(CityManager.scrapChances.values()[i]) + "%"


func _on_common_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellCommonScrap = true
		CityManager.massAutoSell(Item.theItem.COMMON_SCRAP)
	else:
		CityManager.autoSellCommonScrap = false


func _on_rare_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellRareScrap = true
		CityManager.massAutoSell(Item.theItem.RARE_SCRAP)
	else:
		CityManager.autoSellRareScrap = false


func _on_super_rare_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellSuperRareScrap = true
		CityManager.massAutoSell(Item.theItem.SUPER_RARE_SCRAP)
	else:
		CityManager.autoSellSuperRareScrap = false


func _on_legendary_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellLegendaryScrap = true
		CityManager.massAutoSell(Item.theItem.LEGENDARY_SCRAP)
	else:
		CityManager.autoSellLegendaryScrap = false


func _on_unseen_money_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoSellUnseenScrap = true
		CityManager.massAutoSell(Item.theItem.UNSEEN_SCRAP)
	else:
		CityManager.autoSellUnseenScrap = false


func _on_common_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertCommonScrap = true
		CityManager.massAutoScrap(Item.theItem.COMMON_SCRAP)
	else:
		CityManager.autoConvertCommonScrap = false


func _on_rare_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertRareScrap = true
		CityManager.massAutoScrap(Item.theItem.RARE_SCRAP)
	else:
		CityManager.autoConvertRareScrap = false


func _on_super_rare_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertSuperRareScrap = true
		CityManager.massAutoScrap(Item.theItem.SUPER_RARE_SCRAP)
	else:
		CityManager.autoConvertSuperRareScrap = false


func _on_legendary_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertLegendaryScrap = true
		CityManager.massAutoScrap(Item.theItem.LEGENDARY_SCRAP)
	else:
		CityManager.autoConvertLegendaryScrap = false


func _on_unseen_convert_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CityManager.autoConvertUnseenScrap = true
		CityManager.massAutoScrap(Item.theItem.UNSEEN_SCRAP)
	else:
		CityManager.autoConvertUnseenScrap = false
