extends Node

var turretData = {}
var turretXpData = {}
var turretLevel = {}
var xpMaxData = {}

# Use the enum from the Turret class for the array type
var unlockedTurrets: Array[Turret.TurretID] = [
	Turret.TurretID.ARROW_TURRET,
	Turret.TurretID.MINI_SENTRY_TURRET,
	Turret.TurretID.ENERGIZER_TURRET,
	Turret.TurretID.RAILGUN_TURRET,
	Turret.TurretID.ROYAL_TURRET,
	Turret.TurretID.FLAME_TURRET,
	Turret.TurretID.REAPER_TURRET,
	Turret.TurretID.FIREWORK_TURRET,
	Turret.TurretID.SPIDER_TURRET,
	Turret.TurretID.TESLA_TURRET,
	Turret.TurretID.SEISMIC_TURRET,
	Turret.TurretID.GOLD_MINE_TURRET,
	Turret.TurretID.SENTRY_TURRET,
	Turret.TurretID.VOODOO_TURRET,
	Turret.TurretID.ZOMBIE_TURRET,
	Turret.TurretID.MEDIC_TURRET
]

func _ready() -> void:
	loadTurretData()
	loadTurretXpData()
	loadXpMaximum()

func _process(_delta: float) -> void:
	get_tree().call_group("Turret", "attack")

func get_turret_string(id: Turret.TurretID) -> String:
	return Turret.TurretID.keys()[id].to_lower()

func loadTurretByID(id: Turret.TurretID):
	match id:
		Turret.TurretID.ARROW_TURRET:
			return load("res://Turret Scenes/Arrow Turret.tscn")
		Turret.TurretID.MINI_SENTRY_TURRET:
			return load("res://Turret Scenes/Mini Sentry Turret.tscn")
		Turret.TurretID.ENERGIZER_TURRET:
			return load("res://Turret Scenes/Energizer Turret.tscn")
		Turret.TurretID.RAILGUN_TURRET:
			return load("res://Turret Scenes/Railgun Turret.tscn")
		Turret.TurretID.REAPER_TURRET:
			return load("res://Turret Scenes/Reaper Turret.tscn")
		Turret.TurretID.ROYAL_TURRET:
			return load("res://Turret Scenes/Royal Turret.tscn")
		Turret.TurretID.FLAME_TURRET:
			return load("res://Turret Scenes/Flame Turret.tscn")
		Turret.TurretID.FIREWORK_TURRET:
			return load("res://Turret Scenes/Firework Turret.tscn")
		Turret.TurretID.SPIDER_TURRET:
			return load("res://Turret Scenes/Spider Turret.tscn")
		Turret.TurretID.TESLA_TURRET:
			return load("res://Turret Scenes/Tesla Turret.tscn")
		Turret.TurretID.SEISMIC_TURRET:
			return load("res://Turret Scenes/Seismic Turret.tscn")
		Turret.TurretID.GOLD_MINE_TURRET:
			return load("res://Turret Scenes/Gold Mine Turret.tscn")
		Turret.TurretID.SENTRY_TURRET:
			return load("res://Turret Scenes/Sentry Turret.tscn")
		Turret.TurretID.VOODOO_TURRET:
			return load("res://Turret Scenes/Voodoo Turret.tscn")
		Turret.TurretID.ZOMBIE_TURRET:
			return load("res://Turret Scenes/Zombie Turret.tscn")
		Turret.TurretID.MEDIC_TURRET:
			return load("res://Turret Scenes/Medic Turret.tscn")
		_:
			push_error("Turret ID not mapped to scene")

func getTurretTexture(id: Turret.TurretID):
	match id:
		Turret.TurretID.ARROW_TURRET:
			return load("res://Textures/Turrets/Arrow Turret/ArrowTurret.png")
		Turret.TurretID.MINI_SENTRY_TURRET:
			return load("res://Textures/Turrets/Mini Sentry Turret/MiniSentryTurret.png")
		Turret.TurretID.ENERGIZER_TURRET:
			return load("res://Textures/Turrets/Energizer Turret/Energizer Turret.png")
		Turret.TurretID.RAILGUN_TURRET:
			return load("res://Textures/Turrets/Railgun Turret/RailgunTurret.png")
		Turret.TurretID.REAPER_TURRET:
			return load("res://Textures/Turrets/Reaper Turret/ReaperTurret.png")
		Turret.TurretID.ROYAL_TURRET:
			return load("res://Textures/Turrets/Royal Turret/RoyalTurret.png")
		Turret.TurretID.FLAME_TURRET:
			return load("res://Textures/Turrets/Flame Turret/Flame Turret.png")
		Turret.TurretID.FIREWORK_TURRET:
			return load("res://Textures/Turrets/Firework Turret/Firework Turret Bottom.png")
		Turret.TurretID.SPIDER_TURRET:
			return load("res://Textures/Turrets/Spider Turret/Spider Turret.png")
		Turret.TurretID.TESLA_TURRET:
			return load("res://Textures/Turrets/Tesla Turret/Tesla Turret.png")
		Turret.TurretID.SEISMIC_TURRET:
			return load("res://Textures/Turrets/Seismic Turret/SeismicTurret.png")
		Turret.TurretID.GOLD_MINE_TURRET:
			return load("res://Textures/Turrets/Gold Mine Turret/Gold Mine Turret.png")
		Turret.TurretID.SENTRY_TURRET:
			return load("res://Textures/Turrets/Automated Sentry Turret/AutomatedSentryTurret.png")
		Turret.TurretID.VOODOO_TURRET:
			return load("res://Textures/Turrets/Voodoo Turret/Voodoo Turret.png")
		Turret.TurretID.ZOMBIE_TURRET:
			return load("res://Textures/Turrets/Zombie Turret/Zombie Turret.png")
		Turret.TurretID.MEDIC_TURRET:
			return load("res://Textures/Turrets/Healing Turret/Healing Turret.png")

func getTurretStat(id: Turret.TurretID, stat_name: String, default = -1):
	var key = get_turret_string(id)
	if turretData.has(key) and turretData[key].has(stat_name):
		return turretData[key][stat_name]
	return default

func getTurretXp(id: Turret.TurretID):
	var key = get_turret_string(id)
	if turretXpData.has(key):
		return turretXpData[key]
	return -1

func getTurretLevel(id: Turret.TurretID):
	var key = get_turret_string(id)
	if turretLevel.has(key):
		return turretLevel[key]
	return -1

func getListOfProperties(id: Turret.TurretID):
	var key = get_turret_string(id)
	var tracker : int = 0
	var properties : Array = []
	if turretData.has(key):
		for prop in turretData[key]:
			tracker += 1
			if tracker >= 8:
				properties.push_back(prop)
	return properties

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

func draw_range_circle(line2d: Line2D, attack_range: float) -> Line2D:
	line2d.clear_points()
	var steps := 64
	for i in range(steps + 1):
		var angle := (i / float(steps)) * TAU
		line2d.add_point(Vector2(cos(angle), sin(angle)) * attack_range)
	line2d.width = 1.5
	line2d.default_color = Color(0.2, 0.85, 1.0, 0.55)
	line2d.joint_mode = Line2D.LINE_JOINT_ROUND
	line2d.begin_cap_mode = Line2D.LINE_CAP_NONE
	line2d.end_cap_mode = Line2D.LINE_CAP_NONE
	return line2d

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

const STAT_ITEM_SCENE = preload("res://Globals/Scene/TurretDescription/StatisticItem.tscn")

func createPropertiesLabels(turret):
	var labels = []
	

	var turretStatsConfig = {
		"health": ["Health: ", Color.FUCHSIA],
		"armor": ["Armor: ", Color.GRAY],
		"damage": ["Damage: ", Color.RED],
		"reloadTime": ["Reload Time: ", Color.CORAL, "s"],
		"attackRange": ["Range: ", Color.SKY_BLUE],
		"projectileSpeed": ["Projectile Speed: ", Color.CADET_BLUE],
		"maxTurretsEnergized": ["Max Turrets Energized: ", Color.DARK_ORCHID],
		"energizeTime": ["Energize Time: ", Color.BLUE_VIOLET, "s"],
		"energizerDamageBuff": ["Damage Buff: ", Color.MEDIUM_PURPLE, "%"],
		"energizerReloadTimeBuff": ["Reload Time Buff: ", Color.MEDIUM_PURPLE, "%"],
		"energizerAttackRangeBuff": ["Range Buff: ", Color.MEDIUM_PURPLE, "%"],
		"energizerProjctileSpeedBuff": ["Projectile Speed Buff: ", Color.MEDIUM_PURPLE, "%"],
		"explosionDamage": ["Explosion Damage: ", Color.CHOCOLATE],
		"explosionRadius": ["Explosion Radius: ", Color.ROSY_BROWN],
		"pierce": ["Pierce: ", Color.PERU],
		"fireDamage": ["Fire Damage: ", Color.RED],
		"fireTime": ["Fire Duration: ", Color.INDIAN_RED, "s"],
		"executionChance": ["Execution Chance: ", Color.BLACK, "%"],
		"poisonChance": ["Poison Chance: ", Color.MEDIUM_SPRING_GREEN, "%"],
		"poisonDamage": ["Poison Damage: ", Color.SPRING_GREEN],
		"poisonDuration": ["Poison Duration: ", Color.MEDIUM_SEA_GREEN, "s"],
		"moneyGenerated": ["Money Generated: $", Color.GOLD],
		"goldProductionTime": ["Generation Time: ", Color.DARK_GOLDENROD, "s"],
		"healingAmount": ["Healing Amount: ", Color.GREEN_YELLOW],
		"healingTime": ["Healing Time: ", Color.SEA_GREEN, "s"],
		"summonTime": ["Summon Time: ", Color.ROSY_BROWN, "s"],
		"maxKnights": ["Max knights: ", Color.SANDY_BROWN],
		"maxBullets": ["Max Bullets: ", Color.LIGHT_GRAY],
		"shotTime": ["Time Between Shot: ", Color.DARK_GRAY, "s"],
		"currentBullets": ["Current Bullets: ", Color.SLATE_GRAY],
		"damageTickTime": ["Time Between Attack: ", Color.SKY_BLUE, "s"],
		"attackingTime": ["Attacking Time: ", Color.CADET_BLUE, "s"],
		"curseChance": ["Curse Chance: ", Color.MEDIUM_PURPLE, "%"],
		"curseDuration": ["Curse Duration: ", Color.MEDIUM_ORCHID, "s"],
		"curseDamageAmp": ["Curse Damage Amp: ", Color.REBECCA_PURPLE, "%"],
		"turnChance": ["Zombie Turn Chance: ", Color.DARK_GREEN, "%"],
		"turnTime": ["Zombie Time: ", Color.GREEN_YELLOW, "s"],
		"knightDamage": ["Knight Damage: ", Color.SADDLE_BROWN],
		"knightHealth": ["Knight Health: ", Color.FOREST_GREEN]
	}

	for prop in turretStatsConfig:
		var value = turret.get(prop)
		
		# Only create a label if the property actually exists on the turret
		if value != null:
			var config = turretStatsConfig[prop]
			var display_name = config[0]
			var font_color = config[1]
			var suffix = config[2] if config.size() > 2 else ""
			
			var label = Label.new()
 	
			label.text = display_name + str(value) + suffix

			label.add_theme_color_override("font_color", font_color)
			label.add_theme_font_size_override("font_size", 10)
			labels.append(label)

	return labels
