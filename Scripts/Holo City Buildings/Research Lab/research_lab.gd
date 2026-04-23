extends Control

var menu

var currentSlots = 0
var usedSlots = 0
var maxSlots = 10

var workersHere = []

var costMap = {}

var turretsList = []

# int will be the turretID (we can use this for the texture) the timer will be the timer of the current research
var currentResearchingMap : Dictionary[Timer,int] = {}

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

var researchTextureBar1
var researchTextureBar2
var researchTextureBar3
var researchTextureBar4
var researchTextureBar5
var researchTextureBar6
var researchTextureBar7
var researchTextureBar8
var researchTextureBar9
var researchTextureBar10

var purchaseLabel

var researchBarList

var purchaseOne = 1
var purchaseTwo = 1
var purchaseThree = 1
var purchaseFour = 1
var purchaseFive = 1
var purchaseSix = 1
var purchaseSeven = 1
var purchaseEight = 1
var purchaseNine = 1
var purchaseTen = 1

var turretLevelDisplayText1
var turretLevelDisplayText2
var turretLevelDisplayText3
var turretLevelDisplayText4
var turretLevelDisplayText5
var turretLevelDisplayText6
var turretLevelDisplayText7
var turretLevelDisplayText8
var turretLevelDisplayText9
var turretLevelDisplayText10

var currentWorkersLabel

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
	currentTurretResearchButtonLabel2 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot2/turretTwoResearchText
	currentTurretResearchButtonLabel3 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot3/turretThreeResearchText
	currentTurretResearchButtonLabel4 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot4/turretFourResearchText
	currentTurretResearchButtonLabel5 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot5/turretFiveResearchText
	currentTurretResearchButtonLabel6 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot6/turretSixResearchText
	currentTurretResearchButtonLabel7 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot7/turretSevenResearchText
	currentTurretResearchButtonLabel8 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot8/turretEightResearchText
	currentTurretResearchButtonLabel9 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot9/turretNineResearchText
	currentTurretResearchButtonLabel10 = $menuControl/LabBackground/CurrentTurretsSlotGrid/CurrentTurretSlot10/turretTenResearchText

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

	researchTextureBar1 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot1/TextureProgressBar
	researchTextureBar2 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot2/TextureProgressBar
	researchTextureBar3 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot3/TextureProgressBar
	researchTextureBar4 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot4/TextureProgressBar
	researchTextureBar5 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot5/TextureProgressBar
	researchTextureBar6 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot6/TextureProgressBar
	researchTextureBar7 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot7/TextureProgressBar
	researchTextureBar8 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot8/TextureProgressBar
	researchTextureBar9 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot9/TextureProgressBar
	researchTextureBar10 = $menuControl/LabBackground/ResearchSlotGrid/ResearchSlot10/TextureProgressBar

	turretLevelDisplayText1 = $menuControl/LabBackground/LevelDisplayGrid/TurretLevel1
	turretLevelDisplayText2 = $menuControl/LabBackground/LevelDisplayGrid/TurretLevel2
	turretLevelDisplayText3 = $menuControl/LabBackground/LevelDisplayGrid/TurretLevel3
	turretLevelDisplayText4 = $menuControl/LabBackground/LevelDisplayGrid/TurretLevel4
	turretLevelDisplayText5 = $menuControl/LabBackground/LevelDisplayGrid/TurretLevel5
	turretLevelDisplayText6 = $menuControl/LabBackground/LevelDisplayGrid/TurretLevel6
	turretLevelDisplayText7 = $menuControl/LabBackground/LevelDisplayGrid/TurretLevel7
	turretLevelDisplayText8 = $menuControl/LabBackground/LevelDisplayGrid/TurretLevel8
	turretLevelDisplayText9 = $menuControl/LabBackground/LevelDisplayGrid/TurretLevel9
	turretLevelDisplayText10 = $menuControl/LabBackground/LevelDisplayGrid/TurretLevel10

	currentWorkersLabel = $menuControl/LabBackground/CurrentWorkersLabel

	purchaseLabel = $menuControl/LabBackground/PurchaseLabel
	purchaseLabel.text = "[font_size=16][color=white]Purchase Research Slot[/color]
[color=gold]$"+                     str(CityManager.researchLabSlotCost)+"[/color][/font_size]"

	researchBarList = [researchTextureBar1,researchTextureBar2,researchTextureBar3,researchTextureBar4,researchTextureBar5,researchTextureBar6,researchTextureBar7,researchTextureBar8,researchTextureBar9,researchTextureBar10]

	for turret in GameManager.turretsBrought:
		costMap[turret] = CityManager.researchBaseCost * pow((1 + CityManager.researchCostScaling),(GameManager.turretTempLevels.get(turret)-1))
	updateUI()
	

func _process(delta: float) -> void:
	if menu.visible:
		if currentResearchingMap.size() > 0:
			var index = 0
			for timer in currentResearchingMap:
				var elapsed = timer.wait_time - timer.time_left
				var progress = (elapsed / timer.wait_time) * 100
				
				updateProgressTimer(index, progress)
				index += 1

func _on_select_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			menu.show()

func updateResearchCost(turret,amountUpgraded):
	costMap[turret] = snappedf(CityManager.researchBaseCost * pow((1 + CityManager.researchCostScaling),(amountUpgraded-1)),0.1)

func researchTurret(turretID):
	var baseTime = TurretManager.getTurretStat(turretID, "constructionTime")
	#var startMult = CityManager.researchTimeMinScale
	#var endMult = CityManager.researchTimeScale

	# how much to decay per level
	#var totalDecay = startMult - endMult
	#var decayPerLevel = totalDecay / (CityManager.researchMaxLevel - 1)
	# current multiplier
	#var multiplier = startMult - (decayPerLevel * (CityManager.cityLevel - 1))
	# floor so it never goes negative or too fast
	#multiplier = max(multiplier, endMult)

	var totalReduction = getWorkerTotalReduction()
	var researchTime = baseTime * (1.0 - totalReduction)
	#var researchTime = (baseTime * multiplier) * (1.0 - totalReduction)
	researchTime = max(researchTime, 0.5)
	#print("Research Time after clicked: " + str(researchTime))

	usedSlots += 1
	var timer = Timer.new()
	timer.wait_time = researchTime
	timer.one_shot = true 
	add_child(timer)
	
	timer.start()
	currentResearchingMap[timer] = turretID
	
	timer.timeout.connect(researchComplete.bind(timer, turretID))
	
	updateUI()

func updateUI():
	
	purchaseLabel.text = "[font_size=16][color=white]Purchase Research Slot[/color]
[color=gold]$"+                     str(CityManager.researchLabSlotCost)+"[/color][/font_size]"
	
	var textures = [currentTurretImage1,currentTurretImage2,currentTurretImage3,currentTurretImage4,currentTurretImage5,currentTurretImage6,currentTurretImage7,currentTurretImage8,currentTurretImage9,currentTurretImage10]
	# loop through your turrets in the selection and fill the list respectivley with the images
	for i in range(10):
		if i >= 0 and i < GameManager.turretsBrought.size():
			var texture = TurretManager.getTurretTexture(GameManager.turretsBrought[i])
			turretsList.append(GameManager.turretsBrought[i])
			textures[i].texture = texture

	var labels = [currentTurretResearchButtonLabel1,currentTurretResearchButtonLabel2,currentTurretResearchButtonLabel3,currentTurretResearchButtonLabel4,currentTurretResearchButtonLabel5,currentTurretResearchButtonLabel6,currentTurretResearchButtonLabel7,currentTurretResearchButtonLabel8,currentTurretResearchButtonLabel9,currentTurretResearchButtonLabel10]
	for i in range(10):
		labels[i].text = "[font_size=6][color=white]" + str(costMap.get(costMap.keys()[i])) + " Energy[/color][/font_size]"

	textures = [researchSlotTexture1,researchSlotTexture2,researchSlotTexture3,researchSlotTexture4,researchSlotTexture5,researchSlotTexture6,researchSlotTexture7,researchSlotTexture8,researchSlotTexture9,researchSlotTexture10]
	if currentSlots <= maxSlots:
		for i in range(currentSlots):
			textures[i].texture = load("res://Textures/Holo City/empty research slot.png")
	
	for item in researchBarList:
		item.value = 0
	
	for i in range(10):
		if i < currentResearchingMap.values().size():
			var texture = TurretManager.getTurretTexture(currentResearchingMap.values()[i])
			textures[i].texture = texture
		else:
			break

func researchComplete(timer : Timer,turretID):
	usedSlots -= 1
	CityManager.addTurretTempLevel(turretID,1)
	
	currentResearchingMap.erase(timer)
	
	timer.queue_free()
	
	for cit : Citizen in workersHere:
		cit.addJobExperience(Citizen.Job.RESEARCHER)
	
	updateUI()

func updateProgressTimer(index,progress):
	var bar : TextureProgressBar = researchBarList[index]
	bar.value = progress

func _on_turret_one_research_button_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentEnergy >= costMap.get(turretsList[0]):
			purchaseOne += 1
			turretLevelDisplayText1.text = "[font_size=15][color=blue]" + str(purchaseOne) + "[/color][/font_size]"
			updateResearchCost(turretsList[0],purchaseOne)
			researchTurret(turretsList[0])

func _on_turret_two_research_button_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentEnergy >= costMap.get(turretsList[1]):
			purchaseTwo += 1
			turretLevelDisplayText2.text = "[font_size=15][color=blue]" + str(purchaseTwo) + "[/color][/font_size]"
			updateResearchCost(turretsList[1],purchaseTwo)
			researchTurret(turretsList[1])


func _on_turret_three_research_button_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentEnergy >= costMap.get(turretsList[2]):
			purchaseThree += 1
			turretLevelDisplayText3.text = "[font_size=15][color=blue]" + str(purchaseThree) + "[/color][/font_size]"
			updateResearchCost(turretsList[2],purchaseThree)
			researchTurret(turretsList[2])


func _on_turret_four_research_button_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentEnergy >= costMap.get(turretsList[3]):
			purchaseFour += 1
			turretLevelDisplayText4.text = "[font_size=15][color=blue]" + str(purchaseFour) + "[/color][/font_size]"
			updateResearchCost(turretsList[3],purchaseFour)
			researchTurret(turretsList[3])


func _on_turret_five_research_button_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentEnergy >= costMap.get(turretsList[4]):
			purchaseFive += 1
			turretLevelDisplayText5.text = "[font_size=15][color=blue]" + str(purchaseFive) + "[/color][/font_size]"
			updateResearchCost(turretsList[4],purchaseFive)
			researchTurret(turretsList[4])


func _on_turret_six_research_button_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentEnergy >= costMap.get(turretsList[5]):
			purchaseSix += 1
			turretLevelDisplayText6.text = "[font_size=15][color=blue]" + str(purchaseSix) + "[/color][/font_size]"
			updateResearchCost(turretsList[5],purchaseSix)
			researchTurret(turretsList[5])


func _on_turret_seven_research_button_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentEnergy >= costMap.get(turretsList[6]):
			purchaseSeven += 1
			turretLevelDisplayText7.text = "[font_size=15][color=blue]" + str(purchaseSeven) + "[/color][/font_size]"
			updateResearchCost(turretsList[6],purchaseSeven)
			researchTurret(turretsList[6])


func _on_turret_eight_research_button_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentEnergy >= costMap.get(turretsList[7]):
			purchaseEight += 1
			turretLevelDisplayText8.text = "[font_size=15][color=blue]" + str(purchaseEight) + "[/color][/font_size]"
			updateResearchCost(turretsList[7],purchaseEight)
			researchTurret(turretsList[7])


func _on_turret_nine_research_button_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentEnergy >= costMap.get(turretsList[8]):
			purchaseNine += 1
			turretLevelDisplayText9.text = "[font_size=15][color=blue]" + str(purchaseNine) + "[/color][/font_size]"
			updateResearchCost(turretsList[8],purchaseNine)
			researchTurret(turretsList[8])


func _on_turret_ten_research_button_pressed() -> void:
	if usedSlots < currentSlots:
		if CityManager.currentEnergy >= costMap.get(turretsList[9]):
			purchaseTen += 1
			turretLevelDisplayText10.text = "[font_size=15][color=blue]" + str(purchaseTen) + "[/color][/font_size]"
			updateResearchCost(turretsList[9],purchaseTen)
			researchTurret(turretsList[9])


func _on_work_area_body_entered(body: Node2D) -> void:
	if body is Citizen:
		body.setJob(Citizen.Job.RESEARCHER)
		workersHere.append(body)
		currentWorkersLabel.text = "Current Workers: " + str(workersHere.size())
		updateCurrentTimers()
		body.currentState = Citizen.State.WORKING



func _on_work_area_body_exited(body: Node2D) -> void:
	if body is Citizen:
		body.hasJob = false
		body.setJob(Citizen.Job.NONE)
		body.currentState = Citizen.State.IDLE
		workersHere.erase(body)
		currentWorkersLabel.text = "Current Workers: " + str(workersHere.size())
		updateCurrentTimers()

func getWorkerTotalReduction():
	var totalReduction = 0.0
	var jobData = CitizenManager.jobSettingsDict.get("Researcher", {})
	var maxReduction = jobData.get("MaxReductionPercentOverall")
	var maxIndiv = jobData.get("MaxIndividualContribution")
	for cit in workersHere:
		var xp = float(cit.jobExperience.get(Citizen.Job.RESEARCHER))
		var workerReduction = (xp - 1.0) / CitizenManager.maxCitizenJobLevel * maxIndiv 
		totalReduction += workerReduction

	return min(totalReduction, maxReduction)

func updateCurrentTimers():
	var newReduction = getWorkerTotalReduction()
	var jobData = CitizenManager.jobSettingsDict.get("Researcher", {})
	var maxReduction = jobData.get("MaxReductionPercentOverall")

	for timer in currentResearchingMap.keys():
		var turretID = currentResearchingMap[timer]

		# need the base time again to know the total duration
		var baseTime = TurretManager.getTurretStat(turretID, "constructionTime")

		# recalculate the original multiplier for the turret
		#var startMult = CityManager.researchTimeMinScale
		#var endMult = CityManager.researchTimeScale
		#var totalDecay = startMult - endMult
		#var decayPerLevel = totalDecay / (CityManager.researchMaxLevel - 1)
		#var multiplier = max(startMult - (decayPerLevel * (CityManager.cityLevel - 1)), endMult)

		# calc new wait time
		var newResearchTime = (baseTime) * (1.0 - newReduction)
		newResearchTime = max(newResearchTime, maxReduction)

		# rescale the remaining time
		var percentRemaining = timer.time_left / timer.wait_time
		timer.wait_time = newResearchTime
		#print(timer.wait_time)
		timer.start(newResearchTime * percentRemaining)


func _on_purchase_slots_button_pressed() -> void:
	if CityManager.currentMoney >= CityManager.researchLabSlotCost:
		# Subtract current money
		currentSlots+= 1
		CityManager.researchLabSlotCost = CityManager.baseResearchLabSlotCost * (currentSlots * CityManager.researchLabCostMultiplier)
		updateUI()
