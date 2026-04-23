extends Control

var turretList = []

var workersHere = []

var costMap = {}

# These are currently ongoing fabricates, the key is the index, the val is the citizen
var activeBuilds = {}

var fabricationTurretScene = preload("res://Globals/Scene/FabricationTurret.tscn")
var portraitScene = preload("res://Game Scenes/Citizen Portrait.tscn")

var menu

var usedSlots = 0
var currentSlots = 5
var maxSlots = 10

var titleLabel
var descriptionLabel
var purchaseLabel
var currentWorkersLabel
var purchaseSlotsButton

var fabSlotTexture1
var fabSlotTexture2
var fabSlotTexture3
var fabSlotTexture4
var fabSlotTexture5
var fabSlotTexture6
var fabSlotTexture7
var fabSlotTexture8
var fabSlotTexture9
var fabSlotTexture10

var turretAssignButton1
var turretAssignButton2
var turretAssignButton3
var turretAssignButton4
var turretAssignButton5
var turretAssignButton6
var turretAssignButton7
var turretAssignButton8
var turretAssignButton9
var turretAssignButton10

var turretAssignText1
var turretAssignText2
var turretAssignText3
var turretAssignText4
var turretAssignText5
var turretAssignText6
var turretAssignText7
var turretAssignText8
var turretAssignText9
var turretAssignText10

var turretAssignedContainer1
var turretAssignedContainer2
var turretAssignedContainer3
var turretAssignedContainer4
var turretAssignedContainer5
var turretAssignedContainer6
var turretAssignedContainer7
var turretAssignedContainer8
var turretAssignedContainer9
var turretAssignedContainer10

var assignedCitPortrait1
var assignedCitPortrait2
var assignedCitPortrait3
var assignedCitPortrait4
var assignedCitPortrait5
var assignedCitPortrait6
var assignedCitPortrait7
var assignedCitPortrait8
var assignedCitPortrait9
var assignedCitPortrait10

var turretsBroughtTexture1
var turretsBroughtTexture2
var turretsBroughtTexture3
var turretsBroughtTexture4
var turretsBroughtTexture5
var turretsBroughtTexture6
var turretsBroughtTexture7
var turretsBroughtTexture8
var turretsBroughtTexture9
var turretsBroughtTexture10

var turretsBroughtPanel1
var turretsBroughtPanel2
var turretsBroughtPanel3
var turretsBroughtPanel4
var turretsBroughtPanel5
var turretsBroughtPanel6
var turretsBroughtPanel7
var turretsBroughtPanel8
var turretsBroughtPanel9
var turretsBroughtPanel10

var scrapCostText1
var scrapCostText2
var scrapCostText3
var scrapCostText4
var scrapCostText5
var scrapCostText6
var scrapCostText7
var scrapCostText8
var scrapCostText9
var scrapCostText10

var assignedWorkers: Array = [null, null, null, null, null, null, null, null, null, null]

var assignmentButtonList = []
var assignTextList = []
var turretAssignContainerList = []

var selectCitPopup

var selectCitGrid

func _ready() -> void:
	menu = $menuControl
	selectCitPopup = $SelectPopup
	
	if menu.visible:
		menu.hide()
	
	if selectCitPopup.visible:
		selectCitPopup.hide()
	
	titleLabel = $menuControl/Background/Title
	descriptionLabel = $menuControl/Background/Description
	purchaseLabel = $menuControl/Background/PurchaseLabel
	currentWorkersLabel = $menuControl/Background/CurrentWorkersLabel
	purchaseSlotsButton = $menuControl/Background/purchaseSlotsButton
	
	fabSlotTexture1 = $menuControl/Background/FabricateSlotGrid/FabricateSlot1
	fabSlotTexture2 = $menuControl/Background/FabricateSlotGrid/FabricateSlot2
	fabSlotTexture3 = $menuControl/Background/FabricateSlotGrid/FabricateSlot3
	fabSlotTexture4 = $menuControl/Background/FabricateSlotGrid/FabricateSlot4
	fabSlotTexture5 = $menuControl/Background/FabricateSlotGrid/FabricateSlot5
	fabSlotTexture6 = $menuControl/Background/FabricateSlotGrid/FabricateSlot6
	fabSlotTexture7 = $menuControl/Background/FabricateSlotGrid/FabricateSlot7
	fabSlotTexture8 = $menuControl/Background/FabricateSlotGrid/FabricateSlot8
	fabSlotTexture9 = $menuControl/Background/FabricateSlotGrid/FabricateSlot9
	fabSlotTexture10 = $menuControl/Background/FabricateSlotGrid/FabricateSlot10
	
	turretAssignButton1 = $menuControl/Background/FabricateSlotGrid/FabricateSlot1/TurretAssignmentButton1
	turretAssignButton2 = $menuControl/Background/FabricateSlotGrid/FabricateSlot2/TurretAssignmentButton2
	turretAssignButton3 = $menuControl/Background/FabricateSlotGrid/FabricateSlot3/TurretAssignmentButton3
	turretAssignButton4 = $menuControl/Background/FabricateSlotGrid/FabricateSlot4/TurretAssignmentButton4
	turretAssignButton5 = $menuControl/Background/FabricateSlotGrid/FabricateSlot5/TurretAssignmentButton5
	turretAssignButton6 = $menuControl/Background/FabricateSlotGrid/FabricateSlot6/TurretAssignmentButton6
	turretAssignButton7 = $menuControl/Background/FabricateSlotGrid/FabricateSlot7/TurretAssignmentButton7
	turretAssignButton8 = $menuControl/Background/FabricateSlotGrid/FabricateSlot8/TurretAssignmentButton8
	turretAssignButton9 = $menuControl/Background/FabricateSlotGrid/FabricateSlot9/TurretAssignmentButton9
	turretAssignButton10 = $menuControl/Background/FabricateSlotGrid/FabricateSlot10/TurretAssignmentButton10
	
	turretAssignText1 = $menuControl/Background/FabricateSlotGrid/FabricateSlot1/turretAssignText
	turretAssignText2 = $menuControl/Background/FabricateSlotGrid/FabricateSlot2/turretAssignText
	turretAssignText3 = $menuControl/Background/FabricateSlotGrid/FabricateSlot3/turretAssignText
	turretAssignText4 = $menuControl/Background/FabricateSlotGrid/FabricateSlot4/turretAssignText
	turretAssignText5 = $menuControl/Background/FabricateSlotGrid/FabricateSlot5/turretAssignText
	turretAssignText6 = $menuControl/Background/FabricateSlotGrid/FabricateSlot6/turretAssignText
	turretAssignText7 = $menuControl/Background/FabricateSlotGrid/FabricateSlot7/turretAssignText
	turretAssignText8 = $menuControl/Background/FabricateSlotGrid/FabricateSlot8/turretAssignText
	turretAssignText9 = $menuControl/Background/FabricateSlotGrid/FabricateSlot9/turretAssignText
	turretAssignText10 = $menuControl/Background/FabricateSlotGrid/FabricateSlot10/turretAssignText

	turretAssignedContainer1 = $menuControl/Background/FabricateSlotGrid/FabricateSlot1/turretAssignmentContainer1
	turretAssignedContainer2 = $menuControl/Background/FabricateSlotGrid/FabricateSlot2/turretAssignmentContainer2
	turretAssignedContainer3 = $menuControl/Background/FabricateSlotGrid/FabricateSlot3/turretAssignmentContainer3
	turretAssignedContainer4 = $menuControl/Background/FabricateSlotGrid/FabricateSlot4/turretAssignmentContainer4
	turretAssignedContainer5 = $menuControl/Background/FabricateSlotGrid/FabricateSlot5/turretAssignmentContainer5
	turretAssignedContainer6 = $menuControl/Background/FabricateSlotGrid/FabricateSlot6/turretAssignmentContainer6
	turretAssignedContainer7 = $menuControl/Background/FabricateSlotGrid/FabricateSlot7/turretAssignmentContainer7
	turretAssignedContainer8 = $menuControl/Background/FabricateSlotGrid/FabricateSlot8/turretAssignmentContainer8
	turretAssignedContainer9 = $menuControl/Background/FabricateSlotGrid/FabricateSlot9/turretAssignmentContainer9
	turretAssignedContainer10 = $menuControl/Background/FabricateSlotGrid/FabricateSlot10/turretAssignmentContainer10

	assignedCitPortrait1 = $menuControl/Background/FabricateSlotGrid/FabricateSlot1/turretAssignmentContainer1/TextureRect
	assignedCitPortrait2 = $menuControl/Background/FabricateSlotGrid/FabricateSlot2/turretAssignmentContainer2/TextureRect
	assignedCitPortrait3 = $menuControl/Background/FabricateSlotGrid/FabricateSlot3/turretAssignmentContainer3/TextureRect
	assignedCitPortrait4 = $menuControl/Background/FabricateSlotGrid/FabricateSlot4/turretAssignmentContainer4/TextureRect
	assignedCitPortrait5 = $menuControl/Background/FabricateSlotGrid/FabricateSlot5/turretAssignmentContainer5/TextureRect
	assignedCitPortrait6 = $menuControl/Background/FabricateSlotGrid/FabricateSlot6/turretAssignmentContainer6/TextureRect
	assignedCitPortrait7 = $menuControl/Background/FabricateSlotGrid/FabricateSlot7/turretAssignmentContainer7/TextureRect
	assignedCitPortrait8 = $menuControl/Background/FabricateSlotGrid/FabricateSlot8/turretAssignmentContainer8/TextureRect
	assignedCitPortrait9 = $menuControl/Background/FabricateSlotGrid/FabricateSlot9/turretAssignmentContainer9/TextureRect
	assignedCitPortrait10 = $menuControl/Background/FabricateSlotGrid/FabricateSlot10/turretAssignmentContainer10/TextureRect

	turretsBroughtTexture1 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot1
	turretsBroughtTexture2 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot2
	turretsBroughtTexture3 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot3
	turretsBroughtTexture4 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot4
	turretsBroughtTexture5 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot5
	turretsBroughtTexture6 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot6
	turretsBroughtTexture7 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot7
	turretsBroughtTexture8 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot8
	turretsBroughtTexture9 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot9
	turretsBroughtTexture10 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot10

	turretsBroughtPanel1 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot1/Panel
	turretsBroughtPanel2 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot2/Panel
	turretsBroughtPanel3 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot3/Panel
	turretsBroughtPanel4 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot4/Panel
	turretsBroughtPanel5 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot5/Panel
	turretsBroughtPanel6 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot6/Panel
	turretsBroughtPanel7 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot7/Panel
	turretsBroughtPanel8 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot8/Panel
	turretsBroughtPanel9 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot9/Panel
	turretsBroughtPanel10 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot10/Panel

	scrapCostText1 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot1/costText
	scrapCostText2 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot2/costText
	scrapCostText3 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot3/costText
	scrapCostText4 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot4/costText
	scrapCostText5 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot5/costText
	scrapCostText6 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot6/costText
	scrapCostText7 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot7/costText
	scrapCostText8 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot8/costText
	scrapCostText9 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot9/costText
	scrapCostText10 = $menuControl/Background/CurrentTurretsSlotGrid/CurrentTurretSlot10/costText

	selectCitGrid = $SelectPopup/Background/GridContainer

	for turret in GameManager.turretsBrought:
		costMap[turret] = TurretManager.getTurretStat(turret,"price")


	assignmentButtonList = [turretAssignButton1,turretAssignButton2,turretAssignButton3,turretAssignButton4,turretAssignButton5,turretAssignButton6,turretAssignButton7,turretAssignButton8,turretAssignButton9,turretAssignButton10]

	assignTextList = [turretAssignText1,turretAssignText2,turretAssignText3,turretAssignText4,turretAssignText5,turretAssignText6,turretAssignText7,turretAssignText8,turretAssignText9,turretAssignText10]

	turretAssignContainerList = [turretAssignedContainer1,turretAssignedContainer2,turretAssignedContainer3,turretAssignedContainer4,turretAssignedContainer5,turretAssignedContainer6,turretAssignedContainer7,turretAssignedContainer8,turretAssignedContainer9,turretAssignedContainer10]

	updateUI()

func _process(delta: float) -> void:
	if selectCitPopup.visible:
		if not CityManager.assignCit:
			CityManager.assignCit = true
	else:
		CityManager.assignCit = false

func updateUI():
	purchaseLabel.text = "[font_size=16][color=white]Purchase Research Slot[/color]
[color=gold]$"+                     str(CityManager.fabricatorSlotCost)+"[/color][/font_size]"

	var textures = [turretsBroughtTexture1,turretsBroughtTexture2,turretsBroughtTexture3,turretsBroughtTexture4,turretsBroughtTexture5,turretsBroughtTexture6,turretsBroughtTexture7,turretsBroughtTexture8,turretsBroughtTexture9,turretsBroughtTexture10]
	for i in range(10):
		if i >= 0 and i < GameManager.turretsBrought.size():
			var texture = TurretManager.getTurretTexture(GameManager.turretsBrought[i])
			turretList.append(GameManager.turretsBrought[i])
			textures[i].texture = texture

	var labels = [scrapCostText1,scrapCostText2,scrapCostText3,scrapCostText4,scrapCostText5,scrapCostText6,scrapCostText7,scrapCostText8,scrapCostText9,scrapCostText10]
	for i in range(10):
		labels[i].text = "[font_size=6][color=brown]" + str(int(costMap.get(costMap.keys()[i]))) + " Scrap[/color][/font_size]"

	textures = [fabSlotTexture1,fabSlotTexture2,fabSlotTexture3,fabSlotTexture4,fabSlotTexture5,fabSlotTexture6,fabSlotTexture7,fabSlotTexture8,fabSlotTexture9,fabSlotTexture10]
	
	
	if currentSlots <= maxSlots:
		for i in range(currentSlots):
			textures[i].texture = load("res://Textures/Holo City/empty research slot.png")
			if assignedWorkers[i] == null:
				assignmentButtonList[i].show()
				assignTextList[i].show()
				turretAssignContainerList[i].hide()
			else:
				assignmentButtonList[i].hide()
				assignTextList[i].hide()
				turretAssignContainerList[i].show()


func _on_select_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			menu.show()

func finishConstruction(index):
	usedSlots -= 1
	activeBuilds.erase(index)
	updateUI()

func fabricateTurret(turretListIndex):
	var turret = turretList[turretListIndex]  
	usedSlots += 1
	var baseConstructionTime = TurretManager.getTurretStat(turret, "constructionTime")
	var fabScene = fabricationTurretScene.instantiate()

	var fabricateSlotTextures = [fabSlotTexture1,fabSlotTexture2,fabSlotTexture3,
		fabSlotTexture4,fabSlotTexture5,fabSlotTexture6,fabSlotTexture7,
		fabSlotTexture8,fabSlotTexture9,fabSlotTexture10]

	# Find next available slot
	var slotIndex = -1
	for i in range(currentSlots):
		if !activeBuilds.has(i):
			slotIndex = i
			break


	fabricateSlotTextures[slotIndex].add_child(fabScene)
	
	
	if assignedWorkers[slotIndex] == null:
		fabScene.startConstruction(turret, baseConstructionTime, slotIndex)
		activeBuilds[slotIndex] = fabScene
	else:
		# do math for the less build time
		fabScene.startConstruction(turret, baseConstructionTime, slotIndex)
		activeBuilds[slotIndex] = fabScene
		pass

func assignCit(index,cit:Citizen):
	for child in selectCitGrid.get_children():
		child.queue_free()
	assignedWorkers[index] = cit
	cit.currentState = Citizen.State.WORKING
	CityManager.assignCit = false
	updateUI()
	menu.show()
	selectCitPopup.hide()


func _on_turret_fabricate_button_1_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentScrap >= costMap.get(turretList[0]):
			fabricateTurret(0)

func _on_turret_fabricate_button_2_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentScrap >= costMap.get(turretList[1]):
			fabricateTurret(1)


func _on_turret_fabricate_button_3_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentScrap >= costMap.get(turretList[2]):
			fabricateTurret(2)


func _on_turret_fabricate_button_4_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentScrap >= costMap.get(turretList[3]):
			fabricateTurret(3)


func _on_turret_fabricate_button_5_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentScrap >= costMap.get(turretList[4]):
			fabricateTurret(4)


func _on_turret_fabricate_button_6_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentScrap >= costMap.get(turretList[5]):
			fabricateTurret(5)


func _on_turret_fabricate_button_7_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentScrap >= costMap.get(turretList[6]):
			fabricateTurret(6)


func _on_turret_fabricate_button_8_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentScrap >= costMap.get(turretList[7]):
			fabricateTurret(7)


func _on_turret_fabricate_button_9_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentScrap >= costMap.get(turretList[8]):
			fabricateTurret(8)

func _on_turret_fabricate_button_10_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentScrap >= costMap.get(turretList[9]):
			fabricateTurret(9)

func buildSelectPopup(index):
	for cit : Citizen in workersHere:
		if cit.currentJob == Citizen.Job.FABRICATOR and cit.currentState == Citizen.State.IDLE:

			var portrait = portraitScene.instantiate()
		
			portrait.linkCitizen(cit)
			portrait.index = index
		
			selectCitGrid.add_child(portrait)

func _on_work_area_body_entered(body: Node2D) -> void:
	if body is Citizen:
		body.setJob(Citizen.Job.FABRICATOR)
		workersHere.append(body)
		currentWorkersLabel.text = "Current Workers: " + str(workersHere.size())
		body.currentState = Citizen.State.IDLE

func _on_turret_assignment_button_1_pressed() -> void:
	menu.hide()
	selectCitPopup.show()
	buildSelectPopup(0)

func _on_turret_assignment_button_2_pressed() -> void:
	menu.hide()
	selectCitPopup.show()
	buildSelectPopup(1)


func _on_turret_assignment_button_3_pressed() -> void:
	menu.hide()
	selectCitPopup.show()
	buildSelectPopup(2)


func _on_turret_assignment_button_4_pressed() -> void:
	menu.hide()
	selectCitPopup.show()
	buildSelectPopup(3)


func _on_turret_assignment_button_5_pressed() -> void:
	menu.hide()
	selectCitPopup.show()
	buildSelectPopup(4)


func _on_turret_assignment_button_6_pressed() -> void:
	menu.hide()
	selectCitPopup.show()
	buildSelectPopup(5)


func _on_turret_assignment_button_7_pressed() -> void:
	menu.hide()
	selectCitPopup.show()
	buildSelectPopup(6)

func _on_turret_assignment_button_8_pressed() -> void:
	menu.hide()
	selectCitPopup.show()
	buildSelectPopup(7)


func _on_turret_assignment_button_9_pressed() -> void:
	menu.hide()
	selectCitPopup.show()
	buildSelectPopup(8)


func _on_turret_assignment_button_10_pressed() -> void:
	menu.hide()
	selectCitPopup.show()
	buildSelectPopup(9)


func _on_turret_cancel_button_1_pressed() -> void:
	if assignedWorkers[0] != null:
		assignedWorkers[0].currentState = Citizen.State.IDLE
	assignedWorkers[0] = null
	updateUI()
