extends Control

var menu

var currentSlots = 1
var usedSlots = 0
var maxSlots = 10

var costMap = {}

var timerMap = {}

var currentTurretImage1
var currentTurretImage2
var currentTurretImage3
var currentTurretImage4
var currentTurretImage5
var currentTurretImage6
var currentTurretImage7
var currentTurretImage8
var currentTurretImage9
var currentTurretImage10

var currentTurretResearchButton1
var currentTurretResearchButton2
var currentTurretResearchButton3
var currentTurretResearchButton4
var currentTurretResearchButton5
var currentTurretResearchButton6
var currentTurretResearchButton7
var currentTurretResearchButton8
var currentTurretResearchButton9
var currentTurretResearchButton10

var currentTurretResearchButtonLabel1
var currentTurretResearchButtonLabel2
var currentTurretResearchButtonLabel3
var currentTurretResearchButtonLabel4
var currentTurretResearchButtonLabel5
var currentTurretResearchButtonLabel6
var currentTurretResearchButtonLabel7
var currentTurretResearchButtonLabel8
var currentTurretResearchButtonLabel9
var currentTurretResearchButtonLabel10

var researchSlotTexture1
var researchSlotTexture2
var researchSlotTexture3
var researchSlotTexture4
var researchSlotTexture5
var researchSlotTexture6
var researchSlotTexture7
var researchSlotTexture8
var researchSlotTexture9
var researchSlotTexture10

var purchaseLabel

func _ready() -> void:
	menu = $menuControl
	
	if menu.visible:
		menu.hide()

	currentTurretImage1 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot1
	currentTurretImage2 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot2
	currentTurretImage3 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot3
	currentTurretImage4 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot4
	currentTurretImage5 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot5
	currentTurretImage6 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot6
	currentTurretImage7 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot7
	currentTurretImage8 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot8
	currentTurretImage9 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot9
	currentTurretImage10 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot10

	currentTurretResearchButton1 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot1/turretOneResearchButton
	currentTurretResearchButton2 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot2/turretOneResearchButton
	currentTurretResearchButton3 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot3/turretOneResearchButton
	currentTurretResearchButton4 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot4/turretOneResearchButton
	currentTurretResearchButton5 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot5/turretOneResearchButton
	currentTurretResearchButton6 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot6/turretOneResearchButton
	currentTurretResearchButton7 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot7/turretOneResearchButton
	currentTurretResearchButton8 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot8/turretOneResearchButton
	currentTurretResearchButton9 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot9/turretOneResearchButton
	currentTurretResearchButton10 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot10/turretOneResearchButton

	currentTurretResearchButtonLabel1 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot1/turretOneResearchText
	currentTurretResearchButtonLabel2 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot2/turretOneResearchText
	currentTurretResearchButtonLabel3 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot3/turretOneResearchText
	currentTurretResearchButtonLabel4 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot4/turretOneResearchText
	currentTurretResearchButtonLabel5 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot5/turretOneResearchText
	currentTurretResearchButtonLabel6 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot6/turretOneResearchText
	currentTurretResearchButtonLabel7 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot7/turretOneResearchText
	currentTurretResearchButtonLabel8 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot8/turretOneResearchText
	currentTurretResearchButtonLabel9 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot9/turretOneResearchText
	currentTurretResearchButtonLabel10 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot10/turretOneResearchText

	researchSlotTexture1 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot1
	researchSlotTexture2 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot2
	researchSlotTexture3 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot3
	researchSlotTexture4 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot4
	researchSlotTexture5 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot5
	researchSlotTexture6 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot6
	researchSlotTexture7 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot7
	researchSlotTexture8 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot8
	researchSlotTexture9 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot9
	researchSlotTexture10 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot10

	purchaseLabel = $menuControl/LabBackground/PurchaseLabel
	purchaseLabel.text = "[font_size=16][color=white]Purchase Research Slot[/color]
[color=gold]$"+                     str(CityManager.researchLabSlotCost)+"[/color][/font_size]"

	calcResearchCost()
	updateUI()


func _on_select_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			menu.show()

func calcResearchCost():
	for turret in GameManager.turretsBrought:
		costMap[turret] = CityManager.researchBaseCost * pow((1 + CityManager.researchCostScaling),(GameManager.turretTempLevels.get(turret)-1))

func researchTurret(index):
	if currentSlots > usedSlots:
		if CityManager.currentEnergy >= costMap.get(index):
			# Subtract energy
			usedSlots += 1
		

func updateUI():
	var textures = [currentTurretImage1,currentTurretImage2,currentTurretImage3,currentTurretImage4,currentTurretImage5,currentTurretImage6,currentTurretImage7,currentTurretImage8,currentTurretImage9,currentTurretImage10]
	# Loop through your turrets in the selection and fill the list respectivley with the images
	for i in range(10):
		if i >= 0 and i < GameManager.turretsBrought.size():
			var texture = TurretManager.getTurretTexture(GameManager.turretsBrought[i])
			textures[i].texture = texture

	var labels = [currentTurretResearchButtonLabel1,currentTurretResearchButtonLabel2,currentTurretResearchButtonLabel3,currentTurretResearchButtonLabel4,currentTurretResearchButtonLabel5,currentTurretResearchButtonLabel6,currentTurretResearchButtonLabel7,currentTurretResearchButtonLabel8,currentTurretResearchButtonLabel9,currentTurretResearchButtonLabel10]
	for i in range(10):
		labels[i].text = "[font_size=6][color=white]" + str(costMap.get(costMap.keys()[i])) + " Energy[/color][/font_size]"

	textures = [researchSlotTexture1,researchSlotTexture2,researchSlotTexture3,researchSlotTexture4,researchSlotTexture5,researchSlotTexture5,researchSlotTexture6,researchSlotTexture7,researchSlotTexture8,researchSlotTexture9,researchSlotTexture10]
	if currentSlots >= maxSlots:
		for i in range(maxSlots+1):
			textures[i].texture = load("res://Textures/Holo City/empty research slot.png")
	else:
		for i in range(currentSlots):
			textures[i].texture = load("res://Textures/Holo City/empty research slot.png")
			
	

func _on_turret_one_research_button_pressed() -> void:
	researchTurret(1)
