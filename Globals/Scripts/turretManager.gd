extends Node

signal turret_unlocked_signal(turret_id)

var turretData = {}
var minionData = {}

var targetableTurrets: Array = [
	Turret.TurretID.ARROW_TURRET,
	Turret.TurretID.SENTRY_TURRET,
	Turret.TurretID.MINI_SENTRY_TURRET,
	Turret.TurretID.FIREWORK_TURRET,
	Turret.TurretID.RAILGUN_TURRET,
	Turret.TurretID.REAPER_TURRET,
	Turret.TurretID.SPIDER_TURRET,
	Turret.TurretID.VOODOO_TURRET,
	Turret.TurretID.BOOMERANG_TURRET,
	Turret.TurretID.SNIPER_TURRET,
	Turret.TurretID.MORTAR_TURRET,
	Turret.TurretID.GOLD_MINE_TURRET,
]

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
	Turret.TurretID.BOOMERANG_TURRET,
	Turret.TurretID.SNIPER_TURRET,
	Turret.TurretID.MORTAR_TURRET
]

const TURRET_SCENE_PATHS = {
	Turret.TurretID.ARROW_TURRET: "res://Turret Scenes/Arrow Turret.tscn",
	Turret.TurretID.MINI_SENTRY_TURRET: "res://Turret Scenes/Mini Sentry Turret.tscn",
	Turret.TurretID.ENERGIZER_TURRET: "res://Turret Scenes/Energizer Turret.tscn",
	Turret.TurretID.RAILGUN_TURRET: "res://Turret Scenes/Railgun Turret.tscn",
	Turret.TurretID.REAPER_TURRET: "res://Turret Scenes/Reaper Turret.tscn",
	Turret.TurretID.ROYAL_TURRET: "res://Turret Scenes/Royal Turret.tscn",
	Turret.TurretID.FLAME_TURRET: "res://Turret Scenes/Flame Turret.tscn",
	Turret.TurretID.FIREWORK_TURRET: "res://Turret Scenes/Firework Turret.tscn",
	Turret.TurretID.SPIDER_TURRET: "res://Turret Scenes/Spider Turret.tscn",
	Turret.TurretID.TESLA_TURRET: "res://Turret Scenes/Tesla Turret.tscn",
	Turret.TurretID.SEISMIC_TURRET: "res://Turret Scenes/Seismic Turret.tscn",
	Turret.TurretID.GOLD_MINE_TURRET: "res://Turret Scenes/Gold Mine Turret.tscn",
	Turret.TurretID.SENTRY_TURRET: "res://Turret Scenes/Sentry Turret.tscn",
	Turret.TurretID.VOODOO_TURRET: "res://Turret Scenes/Voodoo Turret.tscn",
	Turret.TurretID.ZOMBIE_TURRET: "res://Turret Scenes/Zombie Turret.tscn",
	Turret.TurretID.MEDIC_TURRET: "res://Turret Scenes/Medic Turret.tscn",
	Turret.TurretID.BUBBLE_TURRET: "res://Turret Scenes/Bubble Turret.tscn",
	Turret.TurretID.BOOMERANG_TURRET: "res://Turret Scenes/Boomerang Turret.tscn",
	Turret.TurretID.SNIPER_TURRET: "res://Turret Scenes/Sniper Turret.tscn",
	Turret.TurretID.MORTAR_TURRET: "res://Turret Scenes/Mortar Turret.tscn"

}

const TURRET_TEXTURE_PATHS = {
	Turret.TurretID.ARROW_TURRET: "res://Textures/Turrets/Arrow Turret/ArrowTurret.png",
	Turret.TurretID.MINI_SENTRY_TURRET: "res://Textures/Turrets/Mini Sentry Turret/MiniSentryTurret.png",
	Turret.TurretID.ENERGIZER_TURRET: "res://Textures/Turrets/Energizer Turret/Energizer Turret.png",
	Turret.TurretID.RAILGUN_TURRET: "res://Textures/Turrets/Railgun Turret/RailgunTurret.png",
	Turret.TurretID.REAPER_TURRET: "res://Textures/Turrets/Reaper Turret/ReaperTurret.png",
	Turret.TurretID.ROYAL_TURRET: "res://Textures/Turrets/Royal Turret/RoyalTurret.png",
	Turret.TurretID.FLAME_TURRET: "res://Textures/Turrets/Flame Turret/Flame Turret.png",
	Turret.TurretID.FIREWORK_TURRET: "res://Textures/Turrets/Firework Turret/firework turret.png",
	Turret.TurretID.SPIDER_TURRET: "res://Textures/Turrets/Spider Turret/Spider Turret.png",
	Turret.TurretID.TESLA_TURRET: "res://Textures/Turrets/Tesla Turret/Tesla Turret.png",
	Turret.TurretID.SEISMIC_TURRET: "res://Textures/Turrets/Seismic Turret/SeismicTurret.png",
	Turret.TurretID.GOLD_MINE_TURRET: "res://Textures/Turrets/Gold Mine Turret/Gold Mine Turret.png",
	Turret.TurretID.SENTRY_TURRET: "res://Textures/Turrets/Automated Sentry Turret/AutomatedSentryTurret.png",
	Turret.TurretID.VOODOO_TURRET: "res://Textures/Turrets/Voodoo Turret/Voodoo Turret.png",
	Turret.TurretID.ZOMBIE_TURRET: "res://Textures/Turrets/Zombie Turret/Zombie Turret.png",
	Turret.TurretID.MEDIC_TURRET: "res://Textures/Turrets/Healing Turret/Healing Turret.png",
	Turret.TurretID.BUBBLE_TURRET: "res://Textures/Turrets/Bubble Turret/Bubble Turret.png",
	Turret.TurretID.BOOMERANG_TURRET: "res://Textures/Turrets/Boomerang Turret/Boomerang Turret.png",
	Turret.TurretID.SNIPER_TURRET: "res://Textures/Turrets/Sniper Turret/Sniper Turret.png",
	Turret.TurretID.MORTAR_TURRET: "res://Textures/Turrets/Mortar Turret/Mortar Turret.png"

}

const STAT_ITEM_SCENE = preload("res://Globals/Scene/TurretDescription/StatisticItem.tscn")

var unlockedTurrets: Array[Turret.TurretID] = []
var lockedCommonTurrets: Array[Turret.TurretID] = []
var lockedRareTurrets: Array[Turret.TurretID] = []
var lockedSuperRareTurrets: Array[Turret.TurretID] = []
var lockedLegendaryTurrets: Array[Turret.TurretID] = []
var lockedUnseenTurrets: Array[Turret.TurretID] = []


func _ready() -> void:
	loadTurretData()
	loadMinionData()
	sort_turrets()
	EconomyManager.turret_unlocked_signal.connect(_on_turret_unlocked)

func _on_turret_unlocked(_turret_id) -> void:
	sort_turrets()

func sort_turrets() -> void:
	unlockedTurrets.clear()
	lockedCommonTurrets.clear()
	lockedRareTurrets.clear()
	lockedSuperRareTurrets.clear()
	lockedLegendaryTurrets.clear()
	lockedUnseenTurrets.clear()

	for turretID in ALL_TURRETS:
		if EconomyManager.is_turret_unlocked(turretID):
			unlockedTurrets.append(turretID)
		else:
			var rarity = getTurretStat(turretID, "rarity")
			match rarity:
				"Common": lockedCommonTurrets.append(turretID)
				"Rare": lockedRareTurrets.append(turretID)
				"Super Rare": lockedSuperRareTurrets.append(turretID)
				"Legendary": lockedLegendaryTurrets.append(turretID)
				"Unseen": lockedUnseenTurrets.append(turretID)
				_: push_warning("Unknown rarity for locked turret: " + str(rarity))

func get_turret_string(id: Turret.TurretID) -> String:
	return Turret.TurretID.keys()[id].to_lower()

func get_minion_string(id: Minion.MinionID) -> String:
	return Minion.MinionID.keys()[id].to_lower()

func loadTurretByID(id: Turret.TurretID) -> PackedScene:
	if TURRET_SCENE_PATHS.has(id):
		return load(TURRET_SCENE_PATHS[id])
	push_error("Turret ID not mapped to scene")
	return null

func getTurretTexture(id: Turret.TurretID) -> Texture2D:
	if TURRET_TEXTURE_PATHS.has(id):
		return load(TURRET_TEXTURE_PATHS[id])
	push_error("Turret ID not mapped to texture")
	return null

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

func getListOfProperties(id: Turret.TurretID) -> Array:
	var key = get_turret_string(id)
	var properties : Array = []
	if turretData.has(key):
		var keys = turretData[key].keys()
		# Skips the first 8 properties matching the old tracker >= 8 logic
		for i in range(7, keys.size()):
			properties.append(keys[i])
	return properties

func loadTurretData() -> void:
	var file = FileAccess.open("res://Config/Turret Info.json", FileAccess.READ)
	if file:
		var json_result = JSON.parse_string(file.get_as_text())
		if typeof(json_result) == TYPE_DICTIONARY:
			turretData = json_result
		else:
			push_error("Invalid JSON in Turret Info.json")
	else:
		push_error("Could not open Turret Info.json")

func loadMinionData() -> void:
	var file = FileAccess.open("res://Config/Minion Info.json", FileAccess.READ)
	if file:
		var json_result = JSON.parse_string(file.get_as_text())
		if typeof(json_result) == TYPE_DICTIONARY:
			minionData = json_result
		else:
			push_error("Invalid JSON in Minion Info.json")
	else:
		push_error("Could not open Minion Info.json")

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

func getTurretIdFromString(turret_str: String) -> int:
	var upper_name = turret_str.to_upper()
	if Turret.TurretID.has(upper_name):
		return Turret.TurretID.get(upper_name)
	push_error("XP Manager: Could not find TurretID for string '%s'" % turret_str)
	return -1


# --- LABEL GENERATION ---

# Helper to remove label boilerplate
func _create_stat_label(text: String, color: Color) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 10)
	return label

func createPropertiesLabels(turret: Turret) -> Array:
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
		"maxBubbles": ["Max Bubbles: ", Color.DEEP_SKY_BLUE],
		"maxEnemies": ["Max Enemies: ", Color.DEEP_SKY_BLUE]
	}

	if turret.hasBubble:
		labels.append(_create_stat_label("Bubble Health: " + str(turret.currentBubbleHealth), Color.CORNFLOWER_BLUE))
	if turret.goldenBuff:
		if is_instance_valid(turret.turretProviders["golden"]):
			labels.append(_create_stat_label("Money Produce Chance: %s%%" % str(turret.turretProviders["golden"].killChance), Color.GOLD))
			labels.append(_create_stat_label("Money Produced on Kill: $%s" % str(turret.turretProviders["golden"].extraGold), Color.GOLDENROD))


	# General Stats
	for prop in turretStatsConfig:
		var value = turret.get(prop)
		if value != null:
			var config = turretStatsConfig[prop]
			var suffix = config[2] if config.size() > 2 else ""
			labels.append(_create_stat_label("%s%s%s" % [config[0], str(value), suffix], config[1]))

	# Level Specific Stats
	if turret.level >= 2:
		match turret.turretID:
			Turret.TurretID.ROYAL_TURRET:
				labels.append(_create_stat_label("Archer Summon Chance: %s%%" % turret.archerSummonChance, Color.LIGHT_CYAN))
				labels.append(_create_stat_label("Max Archers: %s" % turret.maxArchers, Color.LIGHT_GRAY))
				labels.append(_create_stat_label("Archer Health: %s" % turret.archerHealth, Color.LIGHT_GREEN))
				labels.append(_create_stat_label("Archer Damage: %s" % turret.archerDamage, Color.LIGHT_CORAL))
				if turret.level >= 3:
					labels.append(_create_stat_label("Bard Summon Chance: %s%%" % turret.bardSummonChance, Color.LIGHT_CYAN))
					labels.append(_create_stat_label("Max Bards: %s" % turret.maxBards, Color.LIGHT_GRAY))
					labels.append(_create_stat_label("Bard Health: %s" % turret.bardHealth, Color.LIGHT_GREEN))
					labels.append(_create_stat_label("Bard Heal: %s" % turret.bardHeal, Color.MEDIUM_SEA_GREEN))

			Turret.TurretID.FLAME_TURRET:
				labels.append(_create_stat_label("Explosion Radius: %s" % turret.explosionRange, Color.ROSY_BROWN))
				if turret.level >= 3:
					labels.append(_create_stat_label("Ignition Rounds Time: %ss" % turret.ignitionRoundsTime, Color.LIGHT_CORAL))

			Turret.TurretID.FIREWORK_TURRET:
				labels.append(_create_stat_label("Ignite Damage: %s" % turret.burnDamage, Color.RED))
				labels.append(_create_stat_label("Ignite Time: %s" % turret.burnTime, Color.INDIAN_RED))
				if turret.level >= 3:
					labels.append(_create_stat_label("Refund Chance: %s%%" % turret.refundChance, Color.DARK_TURQUOISE))

			Turret.TurretID.REAPER_TURRET:
				labels.append(_create_stat_label("Chance Increase: %s%%" % turret.executionIncrease, Color.DARK_GRAY))

			Turret.TurretID.SPIDER_TURRET:
				labels.append(_create_stat_label("Web Chance: %s%%" % turret.webChance, Color.WHITE))
				labels.append(_create_stat_label("Web Duration: %ss" % turret.webDuration, Color.LIGHT_GRAY))

			Turret.TurretID.TESLA_TURRET:
				labels.append(_create_stat_label("Stun Time: %ss" % turret.stunTime, Color.DARK_GRAY))
				if turret.level >= 3:
					labels.append(_create_stat_label("Chain Range: %s" % turret.chainRange, Color.CORNFLOWER_BLUE))

			Turret.TurretID.SEISMIC_TURRET:
				labels.append(_create_stat_label("Reload Damage: %s" % turret.tickDamage, Color.SADDLE_BROWN))
				labels.append(_create_stat_label("Reload Tick Time: %ss" % turret.tickTime, Color.ROSY_BROWN))
				if turret.level >= 3:
					labels.append(_create_stat_label("Chain Range: %s" % turret.chainRange, Color.SANDY_BROWN))

			Turret.TurretID.GOLD_MINE_TURRET:
				labels.append(_create_stat_label("Extra Money: $%s" % turret.extraGold, Color.GOLDENROD))
				labels.append(_create_stat_label("Extra Money Chance: %s%%" % turret.extraChance, Color.PALE_GOLDENROD))

			Turret.TurretID.SENTRY_TURRET:
				labels.append(_create_stat_label("Idle Bullets Reloaded: %s" % turret.notShootingReloadBullets, Color.DIM_GRAY))
				if turret.level >= 3:
					labels.append(_create_stat_label("Shooting Bullets Reloaded: %s" % turret.shootingReloadBullets, Color.LIGHT_GRAY))

			Turret.TurretID.VOODOO_TURRET:
				labels.append(_create_stat_label("Curse Explosion Radius: %s" % turret.curseExplosionRadius, Color.LIGHT_PINK))
				if turret.level >= 3:
					labels.append(_create_stat_label("Damage Reduction: %s%%" % turret.damageReduction, Color.PINK))

			Turret.TurretID.ZOMBIE_TURRET:
				labels.append(_create_stat_label("Gravestone Range: %s" % turret.gravestoneRange, Color.WEB_GRAY))
				labels.append(_create_stat_label("Gravestone Time: %ss" % turret.gravestoneTime, Color.LIGHT_GRAY))

			Turret.TurretID.MEDIC_TURRET:
				labels.append(_create_stat_label("Critical Thresh: %s%%" % (turret.criticalThresh * 100), Color.INDIAN_RED))
				labels.append(_create_stat_label("Bonus Healing: %s" % turret.bonusHeal, Color.PALE_GREEN))
				if turret.level >= 3:
					labels.append(_create_stat_label("Full Heal Chance: %s%%" % turret.fullHealChance, Color.MEDIUM_SPRING_GREEN))

			Turret.TurretID.BUBBLE_TURRET:
				labels.append(_create_stat_label("Armor Provided: %s" % turret.shieldProvided, Color.LIGHT_GRAY))
				if turret.level >= 3:
					labels.append(_create_stat_label("Knockback Radius: %s" % turret.knockbackRange, Color.WHITE_SMOKE))
					labels.append(_create_stat_label("Knockback Velocity: %s" % turret.knockbackVelocity, Color.FLORAL_WHITE))
					labels.append(_create_stat_label("Stun Time: %ss" % turret.stunTime, Color.SLATE_GRAY))

			Turret.TurretID.SNIPER_TURRET:
				labels.append(_create_stat_label("Reload Chance per Kill: %s%%" % turret.reloadChance, Color.DARK_SEA_GREEN))
				if turret.level >= 3:
					labels.append(_create_stat_label("Silver Bullet Chance: %s%%" % turret.silverBulletChance, Color.FLORAL_WHITE))
					labels.append(_create_stat_label("Silver Bullet Damage Multiplier: x%s" % turret.silverBulletDamageMultiplier, Color.PALE_VIOLET_RED))

			Turret.TurretID.MORTAR_TURRET:
				labels.append(_create_stat_label("Fire Pool Time: %ss" % turret.poolTime, Color.ORANGE_RED))
				labels.append(_create_stat_label("Fire Pool Radius: %s" % turret.poolRadius, Color.WHEAT))
				labels.append(_create_stat_label("Fire Pool Ignite Time: %ss" % turret.poolIgniteTime, Color.INDIAN_RED))
				labels.append(_create_stat_label("Fire Pool Ignite Damage: %ss" % turret.poolIgniteDamage, Color.INDIAN_RED))
				if turret.level >= 3:
					labels.append(_create_stat_label("Extra Shots: %s" % turret.extraShots, Color.GRAY))

	return labels

# Helper function for the UI to call
func canTurretTarget(id) -> bool:
	return targetableTurrets.has(id)
