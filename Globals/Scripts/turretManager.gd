extends Node

func _ready() -> void:
	loadTurretData()

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

var turretData = {}

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

		"Arrow Turret":
			return load("res://Textures/Turrets/Arrow Turret/ArrowTurret.png")
		"Mini Sentry Turret":
			return load("res://Textures/Turrets/Mini Sentry Turret/MiniSentryTurret.png")
		"Energizer Turret":
			return load("res://Textures/Turrets/Energizer Turret/Energizer Turret.png")
		"Railgun Turret":
			return load("res://Textures/Turrets/Railgun Turret/RailgunTurret.png")
		"Reaper Turret":
			return load("res://Textures/Turrets/Reaper Turret/ReaperTurret.png")
		"Royal Turret":
			return load("res://Textures/Turrets/Royal Turret/RoyalTurret.png")
		"Flame Turret":
			return load("res://Textures/Turrets/Flame Turret/Flame Turret.png")
		"Firework Turret":
			return load("res://Textures/Turrets/Firework Turret/Firework Turret Bottom.png")
		"Spider Turret":
			return load("res://Textures/Turrets/Spider Turret/Spider Turret.png")
		"Tesla Turret":
			return load("res://Textures/Turrets/Tesla Turret/Tesla Turret.png")
		"Seismic Turret":
			return load("res://Textures/Turrets/Seismic Turret/SeismicTurret.png")
		"Gold Mine Turret":
			return load("res://Textures/Turrets/Gold Mine Turret/Gold Mine Turret.png")
		"Automated Sentry Turret":
			return load("res://Textures/Turrets/Automated Sentry Turret/AutomatedSentryTurret.png")
		"Voodoo Turret":
			return load("res://Textures/Turrets/Voodoo Turret/Voodoo Turret.png")
		"Zombie Turret":
			return load("res://Textures/Turrets/Zombie Turret/Zombie Turret.png")
		"Medic Turret":
			return load("res://Textures/Turrets/Healing Turret/Healing Turret.png")

func getTurretRange(turretName):

	match turretName:

		"Arrow Turret":
			return load("res://Turret Scenes/Arrow Turret.tscn").attackRange
		"Mini Sentry Turret":
			return load("res://Turret Scenes/Mini Sentry Turret.tscn")
		"Energizer Turret":
			return load("res://Turret Scenes/Energizer Turret.tscn")
		"Railgun Turret":
			return load("res://Turret Scenes/Railgun Turret.tscn")
		"Reaper Turret":
			return load("res://Turret Scenes/Reaper Turret.tscn")
		"Royal Turret":
			return load("res://Turret Scenes/Royal Turret.tscn")
		"Flame Turret":
			return load("res://Turret Scenes/Flame Turret.tscn")
		"Firework Turret":
			return load("res://Turret Scenes/Firework Turret.tscn")
		"Spider Turret":
			return load("res://Turret Scenes/Spider Turret.tscn")
		"Tesla Turret":
			return load("res://Turret Scenes/Tesla Turret.tscn")
		"Seismic Turret":
			return load("res://Turret Scenes/Seismic Turret.tscn")
		"Gold Mine Turret":
			return load("res://Turret Scenes/Gold Mine Turret.tscn")
		"Automated Sentry Turret":
			return load("res://Turret Scenes/Automated Sentry Turret.tscn")
		"Voodoo Turret":
			return load("res://Turret Scenes/Voodoo Turret.tscn")
		"Zombie Turret":
			return load("res://Turret Scenes/Zombie Turret.tscn")
		"Medic Turret":
			return load("res://Turret Scenes/Medic Turret.tscn")

func loadTurretData():
	var file := FileAccess.open("res://Config/Turret Info.json", FileAccess.READ)
	if file:
		var json_str = file.get_as_text()
		var json_result = JSON.parse_string(json_str)
		if typeof(json_result) == TYPE_DICTIONARY:
			turretData = json_result
		else:
			push_error("Invalid JSON in Turret Info.json")
	else:
		push_error("Could not open Turret Info.json")

func getTurretStat(turretKey: String, statName: String, default = -1):
	if turretData.has(turretKey) and turretData[turretKey].has(statName):
		return turretData[turretKey][statName]
	return default
