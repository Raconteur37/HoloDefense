extends CanvasLayer

var difficultyNumber = 0
var wavesCompleted = 0
var enemiesKilled = 0
var elapsedTime = 0

var stardustEarned : float
var stardustTotal : int

var tierOneEnemiesKilled = 0
var tierTwoEnemiesKilled = 0
var tierThreeEnemiesKilled = 0
var bossesKilled = 0
var turretsPlaced = 0
var citizensGenerated = 0
var researchCompleted = 0
var difficultyMultiplier = 0
var systemsCompleted = 0

@onready var headerStatusLabel = $PanelContainer/VBoxContainer/Header/HBoxContainer/StatusLabel
@onready var difficultyNumberLabel = $VBoxContainer/DifNumberLabel
@onready var wavesCompletedLabel = $VBoxContainer2/DifNumberLabel
@onready var enemiesKilledLabel = $VBoxContainer3/DifNumberLabel
@onready var elapsedTimeLabel = $VBoxContainer4/DifNumberLabel

@onready var waveStardustLabel = $RewardContainer/VBoxContainer/Header/HBoxContainer/StatusLabel

@onready var tierOneEnemiesKilledLabel = $VBoxContainer5/HBoxContainer/TierOneEnemiesKilled
@onready var tierTwoEnemiesKilledLabel = $VBoxContainer5/HBoxContainer2/TierTwoEnemiesKilled
@onready var tierThreeEnemiesKilledLabel = $VBoxContainer5/HBoxContainer3/TierThreeEnemiesKilled
@onready var bossesKilledLabel = $VBoxContainer5/HBoxContainer4/BossesKilled
@onready var wavesCompletedLabelStardustEarned = $VBoxContainer5/HBoxContainer5/WavesCompleted
@onready var systemsCompletedLabel = $VBoxContainer5/HBoxContainer6/ValueLabel
@onready var turretsPlacedLabel = $VBoxContainer5/HBoxContainer7/ValueLabel
@onready var citizensGeneratedLabel = $VBoxContainer5/HBoxContainer8/ValueLabel
@onready var researchCompletedLabel = $VBoxContainer5/HBoxContainer9/ValueLabel
@onready var stardustEarnedLabel = $VBoxContainer5/HBoxContainer10/ValueLabel
@onready var difficultyMultiplierLabel = $VBoxContainer5/HBoxContainer11/ValueLabel

@onready var stardustTotalLabel = $RewardContainerBottom/HBoxContainer/TotalNumberLabel

@onready var item = $BonusRollsContainer/MarginContainer/BonusHolder/Item
@onready var itemHolderDisplay = $BonusRollsContainer/MarginContainer/BonusHolder

var activeTween

var earnedIndex = 0

var config_data: Dictionary

var rewardConfig: Dictionary = {}


var storedRewards: Array = []

var nextInput = false

func calculateRewards():
	waveStardustLabel.text = "Waves " + str(wavesCompleted)
	
	wavesCompleted = StatManager.wavesCompleted
	enemiesKilled = StatManager.enemiesKilled
	elapsedTime = StatManager.elapsedTime

	tierOneEnemiesKilled = StatManager.tierOneEnemiesKilled
	tierTwoEnemiesKilled = StatManager.tierTwoEnemiesKilled 
	tierThreeEnemiesKilled = StatManager.tierThreeEnemiesKilled
	bossesKilled = StatManager.bossesKilled
	turretsPlaced = StatManager.turretsPlaced
	citizensGenerated = StatManager.citizensGenerated
	researchCompleted = StatManager.researchCompleted
	systemsCompleted = StatManager.systemsCompleted
	difficultyNumber = WaveManager.currentDifficulty
	difficultyMultiplier = getDifficultyMultiplier(difficultyNumber)
	
	stardustEarned = 0
	#enemiesKilled = 10
	tierOneEnemiesKilled = 10
	#turretsPlaced = 6
	#citizensGenerated = 3

	#wavesCompleted = 10
	#elapsedTime = 70
	#tierOneEnemiesKilled = 10
	#tierTwoEnemiesKilled = 1000
	#tierThreeEnemiesKilled = 100
	#bossesKilled = 3
	#stardustTotal = 20000
	
	stardustEarned += wavesCompleted * getParameterValue("wave_completion_value")
	stardustEarned += tierOneEnemiesKilled * getParameterValue("kill_values")[0]
	stardustEarned += tierTwoEnemiesKilled * getParameterValue("kill_values")[1]
	stardustEarned += tierThreeEnemiesKilled * getParameterValue("kill_values")[2]
	stardustEarned += systemsCompleted * getParameterValue("system_completion_value")
	stardustEarned += bossesKilled * getParameterValue("boss_kill_value")
	stardustEarned += turretsPlaced * getParameterValue("turret_generation_value")
	stardustEarned += citizensGenerated * getParameterValue("citizen_creation_value")
	stardustEarned += citizensGenerated * getParameterValue("research_completion_value")
	
	#print(stardustEarned)
	#print(difficultyMultiplier)
	
	#print(floor(stardustEarned * difficultyMultiplier))
	
	stardustTotal = floor(floor(stardustEarned) * difficultyMultiplier)
	
	EconomyManager.add_stardust(stardustTotal)
	EconomyManager.save_economy()
	
	#print(stardustTotal)
	

func _ready():
	config_data = load_json("res://Config/Rewards.json")
	var file = FileAccess.open("res://Config/Rewards.json", FileAccess.READ)
	if file:
		rewardConfig = JSON.parse_string(file.get_as_text())
		file.close()

	setInvisible()

	calculateRewards()
	
	var rollsEarned = floor(stardustTotal / 150)
	for i in rollsEarned:
		tryGrantReward()

	startTweens()
	
	SoundManager.playGameOverMusic(false)
	
	#print(TurretManager.lockedCommonTurrets)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		if nextInput:
			nextInput = false
			get_tree().change_scene_to_file("res://Game Scenes/Main Menu.tscn")
			GameManager.reset()
	if activeTween and activeTween.is_valid():
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			activeTween.set_speed_scale(5.0)
		else:
			activeTween.set_speed_scale(1.0)

func load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var json_text = file.get_as_text()
	var json = JSON.new()
	json.parse(json_text)
	return json.data

func getParameterValue(key: String):
	return config_data["game_constants"]["parameters"][key]

func getDifficultyMultiplier(level: int) -> float:
	return float(config_data["game_constants"]["difficulty_multipliers"][str(level)])


func startTweens():
	if activeTween and activeTween.is_valid():
		activeTween.kill()
	
	activeTween = create_tween().set_parallel(true)
	activeTween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	activeTween.tween_property($PanelContainer,"modulate",Color(1,1,1,1), 1)
	activeTween.tween_property($GridContainer,"modulate",Color(1,1,1,1), 1)
	activeTween.tween_property($VBoxContainer,"modulate",Color(1,1,1,1), 1)
	activeTween.tween_property($VBoxContainer2,"modulate",Color(1,1,1,1), 1)
	activeTween.tween_property($VBoxContainer3,"modulate",Color(1,1,1,1), 1)
	activeTween.tween_property($VBoxContainer4,"modulate",Color(1,1,1,1), 1)
	
	activeTween.set_parallel(false)
	
	activeTween.tween_method(
		func(val: int): difficultyNumberLabel.text = str(val),
		0,
		difficultyNumber,
		1.8
	)
	activeTween.tween_method(
		func(val: int): wavesCompletedLabel.text = str(val),
		0,
		wavesCompleted,
		1.8
	)
	activeTween.tween_method(
		func(val: int): enemiesKilledLabel.text = str(formatNumber(int(val))),
		0,
		float(enemiesKilled),
		2
	)
	activeTween.tween_method(
		func(val: int): elapsedTimeLabel.text = str(formatTime(int(val))),
		0,
		float(elapsedTime),
		2
	)
	
	activeTween.set_parallel(true)
	
	activeTween.tween_property($RewardContainer,"modulate",Color(1,1,1,1), 1)
	activeTween.tween_property($VBoxContainer5,"modulate",Color(1,1,1,1), 1)
	activeTween.tween_property($RewardContainerBottom,"modulate",Color(1,1,1,1), 1)
	
	activeTween.set_parallel(false)
	
	activeTween.tween_callback(_on_timer_timeout)

func setInvisible():
	$PanelContainer.modulate = Color(0,0,0,0)
	$GridContainer.modulate = Color(0,0,0,0)
	$VBoxContainer.modulate = Color(0,0,0,0)
	$VBoxContainer2.modulate = Color(0,0,0,0)
	$VBoxContainer3.modulate = Color(0,0,0,0)
	$VBoxContainer4.modulate = Color(0,0,0,0)
	
	$RewardContainer.modulate = Color(0,0,0,0)
	$VBoxContainer5.modulate = Color(0,0,0,0)
	$RewardContainerBottom.modulate = Color(0,0,0,0)
	
	$BonusRollsContainer.modulate = Color(0,0,0,0)
	
	$VBoxContainer5/HBoxContainer.modulate = Color(0,0,0,0)
	$VBoxContainer5/HSeparator.modulate = Color(0,0,0,0)
	$VBoxContainer5/HBoxContainer2.modulate = Color(0,0,0,0)
	$VBoxContainer5/HSeparator2.modulate = Color(0,0,0,0)
	$VBoxContainer5/HBoxContainer3.modulate = Color(0,0,0,0)
	$VBoxContainer5/HSeparator3.modulate = Color(0,0,0,0)
	$VBoxContainer5/HBoxContainer4.modulate = Color(0,0,0,0)
	$VBoxContainer5/HSeparator4.modulate = Color(0,0,0,0)
	$VBoxContainer5/HBoxContainer5.modulate = Color(0,0,0,0)
	$VBoxContainer5/HSeparator5.modulate = Color(0,0,0,0)
	$VBoxContainer5/HBoxContainer6.modulate = Color(0,0,0,0)
	$VBoxContainer5/HSeparator6.modulate = Color(0,0,0,0)
	$VBoxContainer5/HBoxContainer7.modulate = Color(0,0,0,0)
	$VBoxContainer5/HSeparator7.modulate = Color(0,0,0,0)
	$VBoxContainer5/HBoxContainer8.modulate = Color(0,0,0,0)
	$VBoxContainer5/HSeparator8.modulate = Color(0,0,0,0)
	$VBoxContainer5/HBoxContainer9.modulate = Color(0,0,0,0)
	$VBoxContainer5/HSeparator9.modulate = Color(0,0,0,0)
	$VBoxContainer5/HBoxContainer10.modulate = Color(0,0,0,0)
	$VBoxContainer5/HSeparator10.modulate = Color(0,0,0,0)
	$VBoxContainer5/HBoxContainer11.modulate = Color(0,0,0,0)
	$RewardContainerBottom/HBoxContainer.modulate = Color(0,0,0,0)
	$VBoxContainer5/HBoxContainer11.modulate = Color(0,0,0,0)
	$InfoLabel.modulate = Color(0,0,0,0)
	
func formatNumber(val):
	var stringVal = str(val)
	var formatted = ""
	var count = 0
	
	for i in range(stringVal.length() -1, -1, -1):
		if count > 0 and count % 3 == 0:
			formatted = "," + formatted
		formatted = stringVal[i] + formatted
		count += 1
		
	return formatted

func formatTime(totalSeconds):
	var min = totalSeconds / 60
	var sec = totalSeconds % 60
	return "%02d:%02d" % [min,sec] # certified python hood classic


func _on_timer_timeout() -> void:
	earnedIndex += 1
	
	if activeTween and activeTween.is_valid():
		activeTween.kill()
	
	activeTween = create_tween().set_parallel(false)
	
	match earnedIndex:
		
		1:
			activeTween.tween_property($VBoxContainer5/HBoxContainer,"modulate",Color(1,1,1,1), 0.3)
			countUp(activeTween,tierOneEnemiesKilled,tierOneEnemiesKilledLabel,1)
		2:
			activeTween.tween_property($VBoxContainer5/HSeparator,"modulate",Color(1,1,1,1), 0.3)
			activeTween.tween_callback(_on_timer_timeout)
		3:
			activeTween.tween_property($VBoxContainer5/HBoxContainer2,"modulate",Color(1,1,1,1), 0.3)
			countUp(activeTween,tierTwoEnemiesKilled,tierTwoEnemiesKilledLabel,1)
		4:
			activeTween.tween_property($VBoxContainer5/HSeparator2,"modulate",Color(1,1,1,1), 0.3)
			activeTween.tween_callback(_on_timer_timeout)
		5:
			activeTween.tween_property($VBoxContainer5/HBoxContainer3,"modulate",Color(1,1,1,1), 0.3)
			countUp(activeTween,tierThreeEnemiesKilled,tierThreeEnemiesKilledLabel,1)
		6:
			activeTween.tween_property($VBoxContainer5/HSeparator3,"modulate",Color(1,1,1,1), 0.3)
			activeTween.tween_callback(_on_timer_timeout)
		7:
			activeTween.tween_property($VBoxContainer5/HBoxContainer4,"modulate",Color(1,1,1,1), 0.3)
			countUp(activeTween,bossesKilled,bossesKilledLabel,1)
		8:
			activeTween.tween_property($VBoxContainer5/HSeparator4,"modulate",Color(1,1,1,1), 0.3)
			activeTween.tween_callback(_on_timer_timeout)
		9:
			activeTween.tween_property($VBoxContainer5/HBoxContainer5,"modulate",Color(1,1,1,1), 0.3)
			countUp(activeTween,wavesCompleted,wavesCompletedLabelStardustEarned,1)
		10:
			activeTween.tween_property($VBoxContainer5/HSeparator5,"modulate",Color(1,1,1,1), 0.3)
			activeTween.tween_callback(_on_timer_timeout)
		11:
			activeTween.tween_property($VBoxContainer5/HBoxContainer6,"modulate",Color(1,1,1,1), 0.3)
			countUp(activeTween,systemsCompleted,systemsCompletedLabel,1)
		12:
			activeTween.tween_property($VBoxContainer5/HSeparator6,"modulate",Color(1,1,1,1), 0.3)
			activeTween.tween_callback(_on_timer_timeout)
		13:
			activeTween.tween_property($VBoxContainer5/HBoxContainer7,"modulate",Color(1,1,1,1), 0.3)
			countUp(activeTween,turretsPlaced,turretsPlacedLabel,1)
		14:
			activeTween.tween_property($VBoxContainer5/HSeparator7,"modulate",Color(1,1,1,1), 0.3)
			activeTween.tween_callback(_on_timer_timeout)
		15:
			activeTween.tween_property($VBoxContainer5/HBoxContainer8,"modulate",Color(1,1,1,1), 0.3)
			countUp(activeTween,citizensGenerated,citizensGeneratedLabel,1)
		16:
			activeTween.tween_property($VBoxContainer5/HSeparator8,"modulate",Color(1,1,1,1), 0.3)
			activeTween.tween_callback(_on_timer_timeout)
		17:
			activeTween.tween_property($VBoxContainer5/HBoxContainer9,"modulate",Color(1,1,1,1), 0.3)
			countUp(activeTween,researchCompleted,researchCompletedLabel,1)
		18:
			activeTween.tween_property($VBoxContainer5/HSeparator9,"modulate",Color(1,1,1,1), 0.3)
			activeTween.tween_callback(_on_timer_timeout)
		19:
			activeTween.tween_property($VBoxContainer5/HBoxContainer10,"modulate",Color(1,1,1,1), 0.3)
			countUp(activeTween,stardustEarned,stardustEarnedLabel,1)
		20:
			activeTween.tween_property($VBoxContainer5/HSeparator10,"modulate",Color(1,1,1,1), 0.3)
			activeTween.tween_callback(_on_timer_timeout)
		21:
			difficultyMultiplierLabel.text = "x" + str(getDifficultyMultiplier(difficultyNumber))
			activeTween.tween_property($VBoxContainer5/HBoxContainer11,"modulate",Color(1,1,1,1), 0.5)
			countUp(activeTween,researchCompleted,researchCompletedLabel,1)
		22:
			activeTween.tween_property($RewardContainerBottom/HBoxContainer,"modulate",Color(1,1,1,1), 0.3)
			countUp(activeTween,stardustTotal,stardustTotalLabel,1)
		23:
			activeTween.tween_property($BonusRollsContainer,"modulate",Color(1,1,1,1), 0.5)
			displayStoredRewards()
			activeTween.tween_callback(_on_timer_timeout)
		24:
			activeTween.tween_property($InfoLabel,"modulate",Color(1,1,1,1), 1)
			activeTween.tween_callback(startInput)

func startInput():
	nextInput = true

func countUp(tween,value,label,time):
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.tween_method(
		func(val: int): label.text = str(formatNumber(int(val))),
		0,
		value,
		time
	)
	tween.tween_callback(_on_timer_timeout)


func buildItemChances() -> Array:

	var difficultyData : Dictionary = rewardConfig["difficulties"][str(WaveManager.currentDifficulty)]
	var rewards : Array = difficultyData["rewards"]
	
	var cumulativeWeights: Array = []
	var totalWeight: float = 0.0
	
	for reward in rewards:
		totalWeight += float(reward["weight"])
		cumulativeWeights.append({
			"cumulative": totalWeight,
			"name": reward["name"],
			"value": reward["value"]
		})
	
	return cumulativeWeights

func rollReward() -> Dictionary:
	var difficultyData: Dictionary = rewardConfig["difficulties"][str(WaveManager.currentDifficulty)]
	var dropChance: float = difficultyData["drop_chance"]
	
	if randf() > dropChance:
		return {}  # No reward
	
	var cumulativeWeights : Array = buildItemChances()
	if cumulativeWeights.is_empty():
		return {}
	
	var totalWeight : float = cumulativeWeights.back()["cumulative"]
	var roll : float = randf() * totalWeight
	#print("Roll num: " + str(roll))
	
	for entry in cumulativeWeights:
		if roll <= entry["cumulative"]:
			return {"name": entry["name"], "value": entry["value"]}
	
	var last = cumulativeWeights.back()
	return {"name": last["name"], "value": last["value"]}

func tryGrantReward():
	var result : Dictionary = rollReward()
	
	if result.is_empty():
		#print("No reward dropped.")
		return
	
	storedRewards.append(result)


func groupStoredRewards() -> Array:
	var grouped: Dictionary = {}
	var order: Array = []
	var ungrouped: Array = []

	for reward in storedRewards:
		var key = reward["name"]

		if key.begins_with("Random "):
			ungrouped.append(reward)
			continue

		if grouped.has(key):
			grouped[key]["value"] += reward["value"]
		else:
			grouped[key] = {"name": key, "value": reward["value"]}
			order.append(key)

	var result: Array = []
	for key in order:
		result.append(grouped[key])
	result.append_array(ungrouped)
	return result



func displayStoredRewards():
	item.visible = false

	if storedRewards.is_empty():
		return

	var groupedRewards = groupStoredRewards()

	for reward in groupedRewards:
		var itemInstance = item.duplicate()
		itemInstance.visible = true
		itemInstance.modulate = Color(1,1,1,1)
		itemHolderDisplay.add_child(itemInstance)
		populateItem(itemInstance, reward["name"], reward["value"])


func populateItem(targetItem: Control, itemName: String, amount):
	var itemTexture: TextureRect = targetItem.get_node("HBoxContainer2/HBoxContainer/PanelContainer/ItemTexture")
	var itemNameLabel: Label = targetItem.get_node("HBoxContainer2/HBoxContainer/VBoxContainer/ItemName")
	var itemDescriptionLabel: Label = targetItem.get_node("HBoxContainer2/HBoxContainer/VBoxContainer/ItemDescription")
	var itemAmountLabel: Label = targetItem.get_node("HBoxContainer2/AmountLabel")


	itemTexture.modulate = Color(1,1,1,1)
	itemTexture.material = null

	match itemName:
		"Bonus Stardust":
			itemNameLabel.text = "Stardust"
			itemAmountLabel.text = "x" + str(amount)
			itemDescriptionLabel.text = "Used for a variety of things."
			itemTexture.texture = load("res://Textures/Shop/stardust_128x128.png")
			EconomyManager.add_stardust(amount)
		"Common Fragments":
			itemNameLabel.text = "Common Fragments"
			itemAmountLabel.text = "x" + str(amount)
			itemDescriptionLabel.text = "Can be turned into Common Shards."
			itemTexture.texture = load("res://Textures/Shop/shard_shattered_64x64.png")
			EconomyManager.add_shard_fragments("common_turret",amount)
		"Rare Fragments":
			itemNameLabel.text = "Rare Fragments"
			itemAmountLabel.text = "x" + str(amount)
			itemDescriptionLabel.text = "Can be turned into Rare Shards."
			itemTexture.texture = load("res://Textures/Shop/shard_shattered_64x64.png")
			itemTexture.modulate = Color("4a6cff")
			EconomyManager.add_shard_fragments("rare_turret",amount)
		"Super Rare Fragments":
			itemNameLabel.text = "Super Rare Fragments"
			itemAmountLabel.text = "x" + str(amount)
			itemDescriptionLabel.text = "Can be turned into Super Rare Shards."
			itemTexture.texture = load("res://Textures/Shop/shard_shattered_64x64.png")
			itemTexture.modulate = Color("6c01c1")
			EconomyManager.add_shard_fragments("super_rare_turret",amount)
		"Legendary Fragments":
			itemNameLabel.text = "Legendary Fragments"
			itemAmountLabel.text = "x" + str(amount)
			itemDescriptionLabel.text = "Can be turned into Legendary Shards."
			itemTexture.texture = load("res://Textures/Shop/shard_shattered_64x64.png")
			itemTexture.modulate = Color("e3b11b")
			EconomyManager.add_shard_fragments("legendary_turret",amount)
		"Unseen Fragments":
			itemNameLabel.text = "Unseen Fragments"
			itemAmountLabel.text = "x" + str(amount)
			itemDescriptionLabel.text = "Can be turned into Unseen Shards."
			itemTexture.texture = load("res://Textures/Shop/shard_shattered_64x64.png")
			itemTexture.modulate = Color("fc5d7f")
			EconomyManager.add_shard_fragments("unseen_turret",amount)
		"Common Shards":
			itemNameLabel.text = "Common Shard"
			itemAmountLabel.text = "x" + str(amount)
			itemDescriptionLabel.text = "Four of them can be used to unlock any Common Turret."
			itemTexture.texture = load("res://Textures/Shop/shard_64x64.png")
			EconomyManager.add_shards("common_turret",amount)
		"Rare Shards":
			itemNameLabel.text = "Rare Shard"
			itemAmountLabel.text = "x" + str(amount)
			itemDescriptionLabel.text = "Four of them can be used to unlock any Rare Turret."
			itemTexture.texture = load("res://Textures/Shop/shard_64x64.png")
			itemTexture.modulate = Color("4a6cff")
			EconomyManager.add_shards("rare_turret",amount)
		"Super Rare Shards":
			itemNameLabel.text = "Super Rare Shard"
			itemAmountLabel.text = "x" + str(amount)
			itemDescriptionLabel.text = "Four of them can be used to unlock any Super Rare Turret."
			itemTexture.texture = load("res://Textures/Shop/shard_64x64.png")
			itemTexture.modulate = Color("6c01c1")
			EconomyManager.add_shards("super_rare_turret",amount)
		"Legendary Shards":
			itemNameLabel.text = "Legendary Shard"
			itemAmountLabel.text = "x" + str(amount)
			itemDescriptionLabel.text = "Four of them can be used to unlock any Legendary Turret."
			itemTexture.texture = load("res://Textures/Shop/shard_64x64.png")
			itemTexture.modulate = Color("e3b11b")
			EconomyManager.add_shards("legendary_turret",amount)
		"Unseen Shards":
			itemNameLabel.text = "Unseen Shard"
			itemAmountLabel.text = "x" + str(amount)
			itemDescriptionLabel.text = "Four of them can be used to unlock any Unseen Turret."
			itemTexture.texture = load("res://Textures/Shop/shard_64x64.png")
			itemTexture.modulate = Color("fc5d7f")
			EconomyManager.add_shards("unseen_turret",amount)
		"Random Common Turret":
			if TurretManager.lockedCommonTurrets.size() > 1:
				var turretID = TurretManager.lockedCommonTurrets.pick_random()
				itemNameLabel.text = TurretManager.getTurretStat(turretID,"name")
				itemAmountLabel.text = "Unlocked!"
				itemDescriptionLabel.text = "Congrats! You unlocked a brand new turret!"
				itemTexture.texture = TurretManager.getTurretTexture(turretID)
				EconomyManager.unlock_turret(turretID)
			else:
				itemNameLabel.text = "Unstable Shard"
				itemAmountLabel.text = "x" + str(amount)
				itemDescriptionLabel.text = "Can be used as a shard for any turret rarity."
				itemTexture.texture = load("res://Textures/Shop/shard_64x64.png")
				var shader = load("res://Shaders/unstable.gdshader")
				var shaderMat = ShaderMaterial.new()
				shaderMat.shader = shader
				itemTexture.material = shaderMat
				EconomyManager.add_shards("unstable",amount)
		"Random Rare Turret":
			if TurretManager.lockedRareTurrets.size() > 1:
				var turretID = TurretManager.lockedRareTurrets.pick_random()
				itemNameLabel.text = TurretManager.getTurretStat(turretID,"name")
				itemAmountLabel.text = "Unlocked!"
				itemDescriptionLabel.text = "Congrats! You unlocked a brand new turret!"
				itemTexture.texture = TurretManager.getTurretTexture(turretID)
				EconomyManager.unlock_turret(turretID)
			else:
				itemNameLabel.text = "Unstable Shard"
				itemAmountLabel.text = "x" + str(amount)
				itemDescriptionLabel.text = "Can be used as a shard for any turret rarity."
				itemTexture.texture = load("res://Textures/Shop/shard_64x64.png")
				var shader = load("res://Shaders/unstable.gdshader")
				var shaderMat = ShaderMaterial.new()
				shaderMat.shader = shader
				itemTexture.material = shaderMat
				EconomyManager.add_shards("unstable",amount)
		"Random Super Rare Turret":
			if TurretManager.lockedSuperRareTurrets.size() > 1:
				var turretID = TurretManager.lockedSuperRareTurrets.pick_random()
				itemNameLabel.text = TurretManager.getTurretStat(turretID,"name")
				itemAmountLabel.text = "Unlocked!"
				itemDescriptionLabel.text = "Congrats! You unlocked a brand new turret!"
				itemTexture.texture = TurretManager.getTurretTexture(turretID)
				EconomyManager.unlock_turret(turretID)
			else:
				itemNameLabel.text = "Unstable Shard"
				itemAmountLabel.text = "x" + str(amount)
				itemDescriptionLabel.text = "Can be used as a shard for any turret rarity."
				itemTexture.texture = load("res://Textures/Shop/shard_64x64.png")
				var shader = load("res://Shaders/unstable.gdshader")
				var shaderMat = ShaderMaterial.new()
				shaderMat.shader = shader
				itemTexture.material = shaderMat
				EconomyManager.add_shards("unstable",amount)
		"Random Legendary Turret":
			if TurretManager.lockedLegendaryTurrets.size() > 1:
				var turretID = TurretManager.lockedLegendaryTurrets.pick_random()
				itemNameLabel.text = TurretManager.getTurretStat(turretID,"name")
				itemAmountLabel.text = "Unlocked!"
				itemDescriptionLabel.text = "Congrats! You unlocked a brand new turret!"
				itemTexture.texture = TurretManager.getTurretTexture(turretID)
				EconomyManager.unlock_turret(turretID)
			else:
				itemNameLabel.text = "Unstable Shard"
				itemAmountLabel.text = "x" + str(amount)
				itemDescriptionLabel.text = "Can be used as a shard for any turret rarity."
				itemTexture.texture = load("res://Textures/Shop/shard_64x64.png")
				var shader = load("res://Shaders/unstable.gdshader")
				var shaderMat = ShaderMaterial.new()
				shaderMat.shader = shader
				itemTexture.material = shaderMat
				EconomyManager.add_shards("unstable",amount)
		"Random Unseen Turret":
			if TurretManager.lockedUnseenTurrets.size() > 1:
				var turretID = TurretManager.lockedUnseenTurrets.pick_random()
				itemNameLabel.text = TurretManager.getTurretStat(turretID,"name")
				itemAmountLabel.text = "Unlocked!"
				itemDescriptionLabel.text = "Congrats! You unlocked a brand new turret!"
				itemTexture.texture = TurretManager.getTurretTexture(turretID)
				EconomyManager.unlock_turret(turretID)
			else:
				itemNameLabel.text = "Unstable Shard"
				itemAmountLabel.text = "x" + str(amount)
				itemDescriptionLabel.text = "Can be used as a shard for any turret rarity."
				itemTexture.texture = load("res://Textures/Shop/shard_64x64.png")
				var shader = load("res://Shaders/unstable.gdshader")
				var shaderMat = ShaderMaterial.new()
				shaderMat.shader = shader
				itemTexture.material = shaderMat
				EconomyManager.add_shards("unstable",amount)
	EconomyManager.save_economy()
