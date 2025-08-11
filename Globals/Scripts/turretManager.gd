extends Node

var turretData = {}
var turretXpData = {}
var turretLevel = {}
var xpMaxData = {}

func _ready() -> void:
	loadTurretData()
	loadTurretXpData()
	loadXpMaximum()

func _process(delta: float) -> void:
	get_tree().call_group("Turret", "attack")

var unlockedTurrets = ["Arrow Turret","Mini Sentry Turret","Energizer Turret","Railgun Turret","Royal Turret","Flame Turret"
,"Reaper Turret","Firework Turret","Spider Turret","Tesla Turret","Seismic Turret","Gold Mine Turret"
,"Automated Sentry Turret","Voodoo Turret","Zombie Turret","Medic Turret"]

var allTurrets = [
	"arrow_turret",
	"mini_sentry_turret",
	"energizer_turret",
	"railgun_turret",
	"royal_turret",
	"flame_turret",
	"reaper_turret",
	"firework_turret",
	"spider_turret",
	"tesla_turret",
	"seismic_turret",
	"gold_mine_turret",
	"automated_sentry_turret",
	"voodoo_turret",
	"zombie_turret",
	"medic_turret"
]


func getTurretByName(turretName):

	match turretName:
		"arrow_turret":
			return load("res://Turret Scenes/Arrow Turret.tscn")
		"mini_sentry_turret":
			return load("res://Turret Scenes/Mini Sentry Turret.tscn")
		"energizer_turret":
			return load("res://Turret Scenes/Energizer Turret.tscn")
		"railgun_turret":
			return load("res://Turret Scenes/Railgun Turret.tscn")
		"reaper_turret":
			return load("res://Turret Scenes/Reaper Turret.tscn")
		"royal_turret":
			return load("res://Turret Scenes/Royal Turret.tscn")
		"flame_turret":
			return load("res://Turret Scenes/Flame Turret.tscn")
		"firework_turret":
			return load("res://Turret Scenes/Firework Turret.tscn")
		"spider_turret":
			return load("res://Turret Scenes/Spider Turret.tscn")
		"tesla_turret":
			return load("res://Turret Scenes/Tesla Turret.tscn")
		"seismic_turret":
			return load("res://Turret Scenes/Seismic Turret.tscn")
		"gold_mine_turret":
			return load("res://Turret Scenes/Gold Mine Turret.tscn")
		"automated_sentry_turret":
			return load("res://Turret Scenes/Automated Sentry Turret.tscn")
		"voodoo_turret":
			return load("res://Turret Scenes/Voodoo Turret.tscn")
		"zombie_turret":
			return load("res://Turret Scenes/Zombie Turret.tscn")
		"medic_turret":
			return load("res://Turret Scenes/Medic Turret.tscn")

func findTurretTexture(turretName):

	match turretName:

		"arrow_turret":
			return load("res://Textures/Turrets/Arrow Turret/ArrowTurret.png")
		"mini_sentry_turret":
			return load("res://Textures/Turrets/Mini Sentry Turret/MiniSentryTurret.png")
		"energizer_turret":
			return load("res://Textures/Turrets/Energizer Turret/Energizer Turret.png")
		"railgun_turret":
			return load("res://Textures/Turrets/Railgun Turret/RailgunTurret.png")
		"reaper_turret":
			return load("res://Textures/Turrets/Reaper Turret/ReaperTurret.png")
		"royal_turret":
			return load("res://Textures/Turrets/Royal Turret/RoyalTurret.png")
		"flame_turret":
			return load("res://Textures/Turrets/Flame Turret/Flame Turret.png")
		"firework_turret":
			return load("res://Textures/Turrets/Firework Turret/Firework Turret Bottom.png")
		"spider_turret":
			return load("res://Textures/Turrets/Spider Turret/Spider Turret.png")
		"tesla_turret":
			return load("res://Textures/Turrets/Tesla Turret/Tesla Turret.png")
		"seismic_turret":
			return load("res://Textures/Turrets/Seismic Turret/SeismicTurret.png")
		"gold_mine_turret":
			return load("res://Textures/Turrets/Gold Mine Turret/Gold Mine Turret.png")
		"automated_sentry_turret":
			return load("res://Textures/Turrets/Automated Sentry Turret/AutomatedSentryTurret.png")
		"voodoo_turret":
			return load("res://Textures/Turrets/Voodoo Turret/Voodoo Turret.png")
		"zombie_turret":
			return load("res://Textures/Turrets/Zombie Turret/Zombie Turret.png")
		"medic_turret":
			return load("res://Textures/Turrets/Healing Turret/Healing Turret.png")

func loadTurretData():
	var file = FileAccess.open("res://Config/Turret Info.json", FileAccess.READ)
	if file:
		var json_str = file.get_as_text()
		var json_result = JSON.parse_string(json_str)
		if typeof(json_result) == TYPE_DICTIONARY:
			turretData = json_result
		else:
			push_error("Invalid JSON in Turret Info.json")
	else:
		push_error("Could not open Turret Info.json")

func loadTurretXpData():
	var file = FileAccess.open("res://Config/TurretXP.json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_DICTIONARY:
			if data.has("turret_xp"):
				turretXpData = data["turret_xp"]
			if data.has("turret_level"):
				turretLevel = data["turret_level"]
		else:
			push_error("Invalid JSON format in %s" % "res://Config/TurretXP.json")
	else:
		push_error("Failed to open file: %s" % "res://Config/TurretXP.json")

func loadXpMaximum() -> void:
	var file = FileAccess.open("res://Config/TurretXP.json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_DICTIONARY and data.has("xp_maximum"):
			xpMaxData = data["xp_maximum"]
		else:
			push_error("Invalid JSON format or missing xp_maximum in %s" % "res://Config/TurretXP.json")
	else:
		push_error("Failed to open file: %s" % "res://Config/TurretXP.json")

func getTurretStat(turretKey: String, statName: String, default = -1):
	if turretData.has(turretKey) and turretData[turretKey].has(statName):
		return turretData[turretKey][statName]
	return default

func getTurretXp(turret_name):
	if turretXpData.has(turret_name):
		return turretXpData[turret_name]
	push_error("Turret not found: %s" % turret_name)
	return -1

func getTurretLevel(turret_name):
	if turretLevel.has(turret_name):
		return turretLevel[turret_name]
	push_error("Turret not found: %s" % turret_name)
	return -1

func getMaxXp(rarity: String, level: int):
	if xpMaxData.has(rarity):
		match level:
			2:
				return xpMaxData[rarity]["LevelTwoMaxXP"]
			3:
				return xpMaxData[rarity]["LevelThreeMaxXP"]
		push_error("Invalid level: %s" % level)
	else:
		push_error("Invalid rarity: %s" % rarity)
	return -1
