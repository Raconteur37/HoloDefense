extends Node

signal turret_unlocked_signal(turret_id)

var turretData = {}
var minionData = {}

# Keep a master list of all turrets so we can iterate through them
const ALL_TURRETS: Array[Turret.TurretID] = [
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
	Turret.TurretID.MEDIC_TURRET,
	Turret.TurretID.BUBBLE_TURRET,
	Turret.TurretID.BOOMERANG_TURRET
]

# These start empty and get filled dynamically on _ready
var unlockedTurrets: Array[Turret.TurretID] = []
var lockedCommonTurrets: Array[Turret.TurretID] = []
var lockedRareTurrets: Array[Turret.TurretID] = []
var lockedSuperRareTurrets: Array[Turret.TurretID] = []
var lockedLegendaryTurrets: Array[Turret.TurretID] = []
var lockedUnseenTurrets: Array[Turret.TurretID] = []

func _ready() -> void:
	loadTurretData()
	loadMinionData()
	
	# Sort the turrets into their respective arrays based on Economy data
	sort_turrets()
	
	EconomyManager.turret_unlocked_signal.connect(_on_turret_unlocked)

func _on_turret_unlocked(_turret_id) -> void:
	sort_turrets()

func sort_turrets() -> void:
	# Clear arrays just in case this is called multiple times
	unlockedTurrets.clear()
	lockedCommonTurrets.clear()
	lockedRareTurrets.clear()
	lockedSuperRareTurrets.clear()
	lockedLegendaryTurrets.clear()
	lockedUnseenTurrets.clear()

	# Loop through every turret in the game
	for turretID in ALL_TURRETS:
		if EconomyManager.is_turret_unlocked(turretID):
			unlockedTurrets.append(turretID)
		else:
			# If it's locked, get its rarity and put it in the right list
			var rarity = getTurretStat(turretID, "rarity")
			match rarity:
				"Common":
					lockedCommonTurrets.append(turretID)
				"Rare":
					lockedRareTurrets.append(turretID)
				"Super Rare":
					lockedSuperRareTurrets.append(turretID)
				"Legendary":
					lockedLegendaryTurrets.append(turretID)
				"Unseen":
					lockedUnseenTurrets.append(turretID)
				_:
					push_warning("Unknown rarity for locked turret: " + str(rarity))

func get_turret_string(id: Turret.TurretID) -> String:
	return Turret.TurretID.keys()[id].to_lower()

func get_minion_string(id: Minion.MinionID):
	return Minion.MinionID.keys()[id].to_lower()

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
		Turret.TurretID.BUBBLE_TURRET:
			return load("res://Turret Scenes/Bubble Turret.tscn")
		Turret.TurretID.BOOMERANG_TURRET:
			return load("res://Turret Scenes/Boomerang Turret.tscn")
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
			return load("res://Textures/Turrets/Firework Turret/firework turret.png")
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
		Turret.TurretID.BUBBLE_TURRET:
			return load("res://Textures/Turrets/Bubble Turret/Bubble Turret.png")
		Turret.TurretID.BOOMERANG_TURRET:
			return load("res://Textures/Turrets/Boomerang Turret/Boomerang Turret.png")

func getTurretStat(id: Turret.TurretID, stat_name: String, default = -1):
	var key = get_turret_string(id)
	if turretData.has(key) and turretData[key].has(stat_name):
		return turretData[key][stat_name]
	return default

func getMinionStat(id: Minion.MinionID, stat_name: String, default = 1):
	var key = get_minion_string(id)
	if minionData.has(key) and minionData[key].has(stat_name):
		return minionData[key][stat_name]
	return default

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

func loadMinionData():
	var file = FileAccess.open("res://Config/Minion Info.json", FileAccess.READ)
	if file:
		var json_str = file.get_as_text()
		var json_result = JSON.parse_string(json_str)
		if typeof(json_result) == TYPE_DICTIONARY:
			minionData = json_result
		else:
			push_error("Invalid JSON in Turret Info.json")
	else:
		push_error("Could not open Turret Info.json")

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

const STAT_ITEM_SCENE = preload("res://Globals/Scene/TurretDescription/StatisticItem.tscn")

func createPropertiesLabels(turret : Turret):
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
		"fireDamage": ["Ignite Damage: ", Color.RED],
		"fireTime": ["Ignite Duration: ", Color.INDIAN_RED, "s"],
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
		"knightHealth": ["Knight Health: ", Color.DARK_SLATE_GRAY],
		"knightDamage": ["Knight Damage: ", Color.SLATE_GRAY],
		"bubbleApplyTime": ["Bubble Apply Time: ", Color.CORNFLOWER_BLUE, "s"],
		"bubbleHealth": ["Bubble Provided Health: ", Color.DEEP_SKY_BLUE],
		"maxBubbles": ["Max Bubbles: ", Color.DEEP_SKY_BLUE]
	}
	
	if turret.hasBubble:
		var label = Label.new()
		label.text = "Bubble Health: " + str(turret.currentBubbleHealth)
		label.add_theme_color_override("font_color", Color.CORNFLOWER_BLUE)
		label.add_theme_font_size_override("font_size", 10)
		labels.append(label)
	
	for prop in turretStatsConfig:
		var value = turret.get(prop)
		
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
			
	if turret.level >= 2 and turret.turretID == Turret.TurretID.ROYAL_TURRET:
		var label = Label.new()
		label = Label.new()
		label.text = "Archer Summon Chance: " + str(turret.archerSummonChance) + "%"
		label.add_theme_color_override("font_color", Color.LIGHT_CYAN)
		label.add_theme_font_size_override("font_size", 10)
		labels.append(label)
		label = Label.new()
		label.text = "Max Archers: " + str(turret.maxArchers)
		label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
		label.add_theme_font_size_override("font_size", 10)
		labels.append(label)
		label = Label.new()
		label.text = "Archer Health: " + str(turret.archerHealth)
		label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
		label.add_theme_font_size_override("font_size", 10)
		labels.append(label)
		label = Label.new()
		label.text = "Archer Damage: " + str(turret.archerDamage)
		label.add_theme_color_override("font_color", Color.LIGHT_CORAL)
		label.add_theme_font_size_override("font_size", 10)
		labels.append(label)
	if turret.level >= 3 and turret.turretID == Turret.TurretID.ROYAL_TURRET:
		var label = Label.new()
		label = Label.new()
		label.text = "Bard Summon Chance: " + str(turret.bardSummonChance) + "%"
		label.add_theme_color_override("font_color", Color.LIGHT_CYAN)
		label.add_theme_font_size_override("font_size", 10)
		labels.append(label)
		label = Label.new()
		label.text = "Max Bards: " + str(turret.maxBards)
		label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
		label.add_theme_font_size_override("font_size", 10)
		labels.append(label)
		label = Label.new()
		label.text = "Bard Health: " + str(turret.bardHealth)
		label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
		label.add_theme_font_size_override("font_size", 10)
		labels.append(label)
		label = Label.new()
		label.text = "Bard Heal: " + str(turret.bardHeal)
		label.add_theme_color_override("font_color", Color.MEDIUM_SEA_GREEN)
		label.add_theme_font_size_override("font_size", 10)
		labels.append(label)
	if turret.level >= 2 and turret.turretID == Turret.TurretID.FLAME_TURRET:
		var label = Label.new()
		label.text = "Explosion Radius: " + str(TurretManager.getTurretStat(turret.turretID,"flameExplosionRange"))
		label.add_theme_color_override("font_color", Color.ROSY_BROWN)
		label.add_theme_font_size_override("font_size", 10)
		labels.append(label)
		if turret.level >= 3:
			label = Label.new()
			label.text = "Ignition Rounds Time: " + str(TurretManager.getTurretStat(turret.turretID,"ignitionRoundsTime")) + "s"
			label.add_theme_color_override("font_color", Color.LIGHT_CORAL)
			label.add_theme_font_size_override("font_size", 10)
			labels.append(label)
	if turret.level >= 2 and turret.turretID == Turret.TurretID.FIREWORK_TURRET:
		var label = Label.new()
		label.text = "Ignite Damage: " + str(TurretManager.getTurretStat(turret.turretID,"burnDamage"))
		label.add_theme_color_override("font_color", Color.RED)
		label.add_theme_font_size_override("font_size", 10)
		labels.append(label)
		label = Label.new()
		label.text = "Ignite Time: " + str(TurretManager.getTurretStat(turret.turretID,"burnTime"))
		label.add_theme_color_override("font_color", Color.INDIAN_RED)
		label.add_theme_font_size_override("font_size", 10)
		labels.append(label)
		if turret.level >= 3:
			label = Label.new()
			label.text = "Refund Chance: " + str(TurretManager.getTurretStat(turret.turretID,"refundChance")) + "%"
			label.add_theme_color_override("font_color", Color.DARK_TURQUOISE)
			label.add_theme_font_size_override("font_size", 10)
			labels.append(label)
	if turret.level >= 2 and turret.turretID == Turret.TurretID.REAPER_TURRET:
		var label = Label.new()
		label.text = "Chance Increase: " + str(TurretManager.getTurretStat(turret.turretID,"executionChanceIncrease")) + "%"
		label.add_theme_color_override("font_color", Color.DARK_GRAY)
		label.add_theme_font_size_override("font_size", 10)
		labels.append(label)


	return labels

func getTurretIdFromString(turret_str: String) -> int:
	var upper_name = turret_str.to_upper()
	
	# Check if the uppercase string exists in the enum dictionary
	if Turret.TurretID.has(upper_name):
		return Turret.TurretID.get(upper_name)
		
	# Fallback if the string doesn't match any turret
	push_error("XP Manager: Could not find TurretID for string '%s'" % turret_str)
	return -1
