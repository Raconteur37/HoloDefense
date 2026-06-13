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
@onready var elaspedTimeLabel = $VBoxContainer4/DifNumberLabel

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

var config_data: Dictionary

func calculateRewards():
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
	difficultyMultiplier = WaveManager.currentDifficulty
	systemsCompleted = StatManager.systemsCompleted
	
	stardustEarned = 0
	
	stardustEarned += wavesCompleted * getParameterValue("wave_completion_value")
	stardustEarned += tierOneEnemiesKilled * getParameterValue("kill_values")[0]
	stardustEarned += tierTwoEnemiesKilled * getParameterValue("kill_values")[1]
	stardustEarned += tierThreeEnemiesKilled * getParameterValue("kill_values")[2]
	stardustEarned += systemsCompleted * getParameterValue("system_completion_value")
	stardustEarned += bossesKilled * getParameterValue("boss_kill_value")
	stardustEarned += turretsPlaced * getParameterValue("turret_generation_value")
	stardustEarned += citizensGenerated * getParameterValue("citizen_creation_value")
	stardustEarned += citizensGenerated * getParameterValue("research_completion_value")
	
	difficultyMultiplier = difficultyMultiplier * getDifficultyMultiplier(difficultyMultiplier)
	
	
	
	stardustTotal = 0

func _ready():
	config_data = load_json("res://Config/Rewards.json")







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
