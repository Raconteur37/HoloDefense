extends Control

var turretList = []
var workersHere = []
var costMap = {}
var activeBuilds = {}

var fabricationTurretScene = preload("res://Globals/Scene/FabricationTurret.tscn")
var portraitScene = preload("res://Game Scenes/Citizen Portrait.tscn")
var removeTurretTexture = preload("res://Textures/Citizens/UI/remove auto build.png")
var emptyTurretAutoBuildTexture = preload("res://Textures/Holo City/empty turret select.png")

@onready var menu = $menuControl
@onready var selectCitPopup = $SelectPopup
@onready var selectCitGrid = $SelectPopup/Background/GridContainer

var usedSlots = 0
var currentSlots = 0
var maxSlots = 10
var autoBuildSelect = -1

var titleLabel
var descriptionLabel
var purchaseLabel
var currentWorkersLabel
var purchaseSlotsButton

# All slot node references stored as arrays
var fabSlotTextures: Array = []
var assignmentButtons: Array = []
var assignTexts: Array = []
var assignContainers: Array = []
var citPortraits: Array = []
var turretBroughtTextures: Array = []
var turretBroughtPanels: Array = []
var scrapCostTexts: Array = []
var autoBuildButtons: Array = []

var assignedWorkers: Array = [null,null,null,null,null,null,null,null,null,null]
var assignedAutoBuildList: Array = [null,null,null,null,null,null,null,null,null,null]

var glowShader
var materialAbstract


func _ready() -> void:
	menu.hide()
	selectCitPopup.hide()

	titleLabel           = $menuControl/Background/Title
	descriptionLabel     = $menuControl/Background/Description
	purchaseLabel        = $menuControl/Background/PurchaseLabel
	currentWorkersLabel  = $menuControl/Background/CurrentWorkersLabel
	purchaseSlotsButton  = $menuControl/Background/purchaseSlotsButton

	# Build all slot arrays by index so everything is data-driven
	for i in range(1, 11):
		var slot = $menuControl/Background/FabricateSlotGrid.get_node("FabricateSlot%d" % i)
		fabSlotTextures.append(slot)
		assignmentButtons.append(slot.get_node("TurretAssignmentButton%d" % i))
		assignTexts.append(slot.get_node("turretAssignText"))
		assignContainers.append(slot.get_node("turretAssignmentContainer%d" % i))
		citPortraits.append(slot.get_node("turretAssignmentContainer%d/TextureRect" % i))
		autoBuildButtons.append(slot.get_node(
			"turretAssignmentContainer%d/VBoxContainer/TurretAutoBuild%d" % [i, i]))

		var currentSlot = $menuControl/Background/CurrentTurretsSlotGrid.get_node("CurrentTurretSlot%d" % i)
		turretBroughtTextures.append(currentSlot)
		turretBroughtPanels.append(currentSlot.get_node("Panel"))
		scrapCostTexts.append(currentSlot.get_node("costText"))

	for turret in GameManager.turretsBrought:
		costMap[turret] = TurretManager.getTurretStat(turret, "price")

	updateUI()


func _process(_delta: float) -> void:
	CityManager.assignCit = selectCitPopup.visible


# ─────────────────────────────────────────────
#  UI
# ─────────────────────────────────────────────

func updateUI() -> void:
	purchaseLabel.text = "[font_size=16][color=white]Purchase Fabricator Slot[/color]\n[color=gold]$%s[/color][/font_size]" \
		% str(CityManager.fabricatorSlotCost)

	for i in range(10):
		# Turrets brought row
		if i < GameManager.turretsBrought.size():
			turretBroughtTextures[i].texture = TurretManager.getTurretTexture(GameManager.turretsBrought[i])
			turretList.append(GameManager.turretsBrought[i])

		if i < scrapCostTexts.size() and i < costMap.keys().size():
			scrapCostTexts[i].text = "[font_size=6][color=brown]%d Scrap[/color][/font_size]" \
				% int(costMap.get(costMap.keys()[i]))

		# Fabrication slots
		if i < currentSlots:
			fabSlotTextures[i].texture = load("res://Textures/Holo City/empty research slot.png")
			var hasWorker = assignedWorkers[i] != null
			assignmentButtons[i].visible = not hasWorker
			assignTexts[i].visible = not hasWorker
			assignContainers[i].visible = hasWorker


func assignButtonGlow() -> void:
	if autoBuildSelect == -1:
		return
	glowShader = load("res://Shaders/pulsing_glow.gdshader")
	for panel in turretBroughtPanels:
		var mat = ShaderMaterial.new()
		mat.shader = glowShader
		panel.material = mat


func removeButtonGlow() -> void:
	for panel in turretBroughtPanels:
		panel.material = null


# ─────────────────────────────────────────────
#  Fabrication
# ─────────────────────────────────────────────

func fabricateTurret(turretListIndex: int) -> void:
	if usedSlots >= currentSlots:
		return
	var turret = turretList[turretListIndex]
	if CityManager.currentScrap < costMap.get(turret):
		return

	CityManager.currentScrap -= costMap.get(turret)
	usedSlots += 1

	var slotIndex := _nextFreeSlot()
	if slotIndex == -1:
		return

	var fabScene = fabricationTurretScene.instantiate()
	fabSlotTextures[slotIndex].add_child(fabScene)

	var constructionTime = _getConstructionTime(turret, slotIndex)
	fabScene.startConstruction(turret, constructionTime, slotIndex)
	activeBuilds[slotIndex] = fabScene


func autoFabricate(turretListIndex: int, slot: int) -> void:
	if usedSlots >= currentSlots or activeBuilds.has(slot):
		return
	var turret = turretList[turretListIndex]
	if CityManager.currentScrap < costMap.get(turret):
		return

	CityManager.currentScrap -= costMap.get(turret)
	usedSlots += 1

	var fabScene = fabricationTurretScene.instantiate()
	fabSlotTextures[slot].add_child(fabScene)

	var constructionTime = _getConstructionTime(turret, slot)
	fabScene.startConstruction(turret, constructionTime, slot)
	activeBuilds[slot] = fabScene


func finishConstruction(index: int, turretID) -> void:
	usedSlots -= 1
	activeBuilds.erase(index)
	GameManager.addTurretToStorage(turretID, 1)
	# Re-trigger any auto builds
	for i in range(assignedAutoBuildList.size()):
		if assignedAutoBuildList[i] != null:
			autoFabricate(assignedAutoBuildList[i], i)
	updateUI()


func _getConstructionTime(turret, slotIndex: int) -> float:
	var base = TurretManager.getTurretStat(turret, "constructionTime")
	var worker = assignedWorkers[slotIndex]
	if worker == null:
		return base
	var jobData = CitizenManager.jobSettingsDict.get("Fabricator", {})
	var maxReduction = jobData.get("MaxReductionPercent", 0.0)
	var xp = float(worker.jobExperience.get(Citizen.Job.FABRICATOR, 1.0))
	var reduction = clamp((xp - 1.0) / CitizenManager.maxCitizenJobLevel * maxReduction, 0.0, 0.8)
	return base * (1.0 - reduction)


func _nextFreeSlot() -> int:
	for i in range(currentSlots):
		if not activeBuilds.has(i):
			return i
	return -1


# ─────────────────────────────────────────────
#  Auto build button (one handler for all 10)
# ─────────────────────────────────────────────

func _on_auto_build_pressed(index: int) -> void:
	# Deselect if already selecting
	if autoBuildSelect != -1:
		autoBuildSelect = -1
		removeButtonGlow()
		return

	# Toggle off if already set
	if assignedAutoBuildList[index] != null:
		assignedAutoBuildList[index] = null
		autoBuildButtons[index].texture_normal = emptyTurretAutoBuildTexture
		autoBuildButtons[index].texture_hover = null
	else:
		autoBuildSelect = index
		assignButtonGlow()


func _on_turret_fabricate_pressed(turretListIndex: int) -> void:
	if autoBuildSelect != -1 and assignedAutoBuildList[autoBuildSelect] == null:
		assignedAutoBuildList[autoBuildSelect] = turretListIndex
		autoBuildButtons[autoBuildSelect].texture_normal = TurretManager.getTurretTexture(
			GameManager.turretsBrought[turretListIndex])
		autoBuildButtons[autoBuildSelect].texture_hover = removeTurretTexture
		removeButtonGlow()
		autoFabricate(turretListIndex, autoBuildSelect)
		autoBuildSelect = -1
		return
	fabricateTurret(turretListIndex)


func _on_cancel_pressed(index: int) -> void:
	if assignedWorkers[index] != null:
		assignedWorkers[index].currentState = Citizen.State.IDLE
		if assignedAutoBuildList[index] != null:
			assignedAutoBuildList[index] = null
			autoBuildButtons[index].texture_normal = emptyTurretAutoBuildTexture
			autoBuildButtons[index].texture_hover = null
	assignedWorkers[index] = null
	updateUI()


func _on_assignment_button_pressed(index: int) -> void:
	menu.hide()
	selectCitPopup.show()
	buildSelectPopup(index)


# ─────────────────────────────────────────────
#  Citizens
# ─────────────────────────────────────────────

func buildSelectPopup(index: int) -> void:
	for cit: Citizen in workersHere:
		if cit.currentJob == Citizen.Job.FABRICATOR and cit.currentState == Citizen.State.IDLE:
			var portrait = portraitScene.instantiate()
			portrait.linkCitizen(cit)
			portrait.index = index
			selectCitGrid.add_child(portrait)


func assignCit(index: int, cit: Citizen) -> void:
	for child in selectCitGrid.get_children():
		child.queue_free()
	assignedWorkers[index] = cit
	cit.currentState = Citizen.State.WORKING
	CityManager.assignCit = false
	updateUI()
	menu.show()
	selectCitPopup.hide()


func _on_work_area_body_entered(body: Node2D) -> void:
	if body is Citizen:
		body.setJob(Citizen.Job.FABRICATOR)
		workersHere.append(body)
		currentWorkersLabel.text = "Current Workers: " + str(workersHere.size())
		body.currentState = Citizen.State.IDLE


# ─────────────────────────────────────────────
#  Misc signals
# ─────────────────────────────────────────────

func _on_select_area_input_event(_viewport, event: InputEvent, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		menu.show()


func _on_menu_control_visibility_changed() -> void:
	if not menu.visible and autoBuildSelect != -1:
		autoBuildSelect = -1
		removeButtonGlow()


func _on_select_popup_visibility_changed() -> void:
	if not selectCitPopup.visible:
		for child in selectCitGrid.get_children():
			child.queue_free()


func _on_purchase_slots_button_pressed() -> void:
	if CityManager.currentMoney >= CityManager.fabricatorSlotCost:
		CityManager.currentMoney -= CityManager.fabricatorSlotCost
		CityManager.addCityXp("purchase_upgrade")
		currentSlots += 1
		if currentSlots >= maxSlots:
			purchaseSlotsButton.hide()
		CityManager.fabricatorSlotCost = CityManager.baseFabricatorSlotCost * (currentSlots * CityManager.fabricatorCostMultiplier)
		updateUI()


func _on_texture_button_pressed() -> void:
	selectCitPopup.hide()
	menu.show()


func _on_turret_auto_build_1_pressed() -> void:
	_on_auto_build_pressed(0)
func _on_turret_cancel_button_1_pressed() -> void:
	_on_cancel_pressed(0)
func _on_turret_fabricate_button_1_pressed() -> void:
	_on_turret_fabricate_pressed(0)
func _on_turret_assignment_button_1_pressed() -> void:
	_on_assignment_button_pressed(0)

func _on_turret_auto_build_2_pressed() -> void:
	_on_auto_build_pressed(1)
func _on_turret_cancel_button_2_pressed() -> void:
	_on_cancel_pressed(1)
func _on_turret_fabricate_button_2_pressed() -> void:
	_on_turret_fabricate_pressed(1)
func _on_turret_assignment_button_2_pressed() -> void:
	_on_assignment_button_pressed(1)

func _on_turret_auto_build_3_pressed() -> void:
	_on_auto_build_pressed(2)
func _on_turret_cancel_button_3_pressed() -> void:
	_on_cancel_pressed(2)
func _on_turret_fabricate_button_3_pressed() -> void:
	_on_turret_fabricate_pressed(2)
func _on_turret_assignment_button_3_pressed() -> void:
	_on_assignment_button_pressed(2)

func _on_turret_auto_build_4_pressed() -> void:
	_on_auto_build_pressed(3)
func _on_turret_cancel_button_4_pressed() -> void:
	_on_cancel_pressed(3)
func _on_turret_fabricate_button_4_pressed() -> void:
	_on_turret_fabricate_pressed(3)
func _on_turret_assignment_button_4_pressed() -> void:
	_on_assignment_button_pressed(3)

func _on_turret_auto_build_5_pressed() -> void:
	_on_auto_build_pressed(4)
func _on_turret_cancel_button_5_pressed() -> void:
	_on_cancel_pressed(4)
func _on_turret_fabricate_button_5_pressed() -> void:
	_on_turret_fabricate_pressed(4)
func _on_turret_assignment_button_5_pressed() -> void:
	_on_assignment_button_pressed(4)

func _on_turret_auto_build_6_pressed() -> void:
	_on_auto_build_pressed(5)
func _on_turret_cancel_button_6_pressed() -> void:
	_on_cancel_pressed(5)
func _on_turret_fabricate_button_6_pressed() -> void:
	_on_turret_fabricate_pressed(5)
func _on_turret_assignment_button_6_pressed() -> void:
	_on_assignment_button_pressed(5)

func _on_turret_auto_build_7_pressed() -> void:
	_on_auto_build_pressed(6)
func _on_turret_cancel_button_7_pressed() -> void:
	_on_cancel_pressed(6)
func _on_turret_fabricate_button_7_pressed() -> void:
	_on_turret_fabricate_pressed(6)
func _on_turret_assignment_button_7_pressed() -> void:
	_on_assignment_button_pressed(6)

func _on_turret_auto_build_8_pressed() -> void:
	_on_auto_build_pressed(7)
func _on_turret_cancel_button_8_pressed() -> void:
	_on_cancel_pressed(7)
func _on_turret_fabricate_button_8_pressed() -> void:
	_on_turret_fabricate_pressed(7)
func _on_turret_assignment_button_8_pressed() -> void:
	_on_assignment_button_pressed(7)

func _on_turret_auto_build_9_pressed() -> void:
	_on_auto_build_pressed(8)
func _on_turret_cancel_button_9_pressed() -> void:
	_on_cancel_pressed(8)
func _on_turret_fabricate_button_9_pressed() -> void:
	_on_turret_fabricate_pressed(8)
func _on_turret_assignment_button_9_pressed() -> void:
	_on_assignment_button_pressed(8)

func _on_turret_auto_build_10_pressed() -> void:
	_on_auto_build_pressed(9)
func _on_turret_cancel_button_10_pressed() -> void:
	_on_cancel_pressed(9)
func _on_turret_fabricate_button_10_pressed() -> void:
	_on_turret_fabricate_pressed(9)
func _on_turret_assignment_button_10_pressed() -> void:
	_on_assignment_button_pressed(9)
