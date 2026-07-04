extends Control

var turretContainer

@onready var scroll = $ScrollContainer
@onready var hbox = $ScrollContainer/HBoxContainer

@onready var turretIcon = $"../VBoxContainer3/Viewport Holder/TurretIcon"
@onready var turretNameLabel = $"../VBoxContainer3/TurretNameLabel"
@onready var turretDescriptionLabel = $"../LevelContainer/LevelOneTexture/RichTextLabel"
@onready var rarityLabel = $"../VBoxContainer3/RarityLabel"
@onready var typeLabel = $"../VBoxContainer3/TypeLabel"

@onready var infoLabelContainer = $"../Info Labels Container"
@onready var previewToggle = $"../VBoxContainer3/PreviewButton"
@onready var viewportContainer = $"../VBoxContainer3/Viewport Holder/SubViewportContainer"
@onready var viewPort = $"../VBoxContainer3/Viewport Holder/SubViewportContainer/SubViewport"

@onready var levelTwoProgressBar = $"../LevelContainer/LevelTwoTexture/LevelTwoProgress"
@onready var levelTwoDescription = $"../LevelContainer/LevelTwoTexture/TurretDescriptionLabel"
@onready var levelThreeProgressBar = $"../LevelContainer/LevelThreeTexture/LevelThreeProgress"
@onready var levelThreeDescription = $"../LevelContainer/LevelThreeTexture/TurretDescriptionLabel"

@onready var levelTwoTexture = $"../LevelContainer/LevelTwoTexture"
@onready var levelThreeTexture = $"../LevelContainer/LevelThreeTexture"

@onready var unlockedIcon = load("res://Textures/UI/Game/Turret Info Scene/GenericButton.png")
@onready var lockedIcon = load("res://Textures/UI/Game/Turret Info Scene/LockedButton.png")
@onready var animationPlayer = $"../AnimationPlayer"
@onready var turretLabel = preload("res://Labels/turret_info_label.tres")
@onready var soundPlayer = $"../../TurretSelectSound"

@onready var toggleStatsButton = $"../../HBoxContainer/StatsToggle"

@onready var statsBox = $"../../HBoxContainer"

@onready var purchaseBox = $"../../PurchaseBox"
@onready var purchaseLabel1 = $"../../PurchaseLabel"
@onready var purchaseLabel2 = $"../../PurchaseLabel2"

@onready var shardButton = $"../../PurchaseBox/ShardButton"
@onready var shardImage =  $"../../PurchaseBox/ShardImage"


@onready var desaturateShader = preload("res://Shaders/desaturate.gdshader")

var shardOverlay: GridContainer
var shardSlots: Array[Panel] = []

# Placeholder balance numbers — replace with your real per-rarity shard costs
const SHARDS_TO_UNLOCK := {
	"Common": 4,
	"Rare": 4,
	"Super Rare": 4,
	"Legendary": 4,
	"Unseen": 4
}

var currentTurretID: Turret.TurretID = Turret.TurretID.NONE
var currentRarityShard = "common_turret"

func _idToName(turretID: Turret.TurretID) -> String:
	return Turret.TurretID.keys()[turretID].to_lower()


func _ready() -> void:
	GameManager.previewMode = true
	scroll.custom_minimum_size = Vector2(700, 150)

	var mat := ShaderMaterial.new()
	mat.shader = desaturateShader
	turretIcon.material = mat

	_build_shard_overlay()

	for rarity in ["Common", "Rare", "Super Rare", "Legendary", "Unseen"]:
		for turretID in TurretManager.ALL_TURRETS:
			if TurretManager.getTurretStat(turretID, "rarity") == rarity:
				add_turret_button(turretID)

	_on_turret_button_pressed(Turret.TurretID.ARROW_TURRET)

func add_turret_button(turretID: Turret.TurretID) -> void:
	var btn := Button.new()
	btn.name = _idToName(turretID)
	btn.icon = TurretManager.getTurretTexture(turretID)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.tooltip_text = _idToName(turretID)
	btn.pressed.connect(_on_turret_button_pressed.bind(turretID))
	if not EconomyManager.is_turret_unlocked(turretID):
		var rect := TextureRect.new()
		rect.texture = load("res://Textures/UI/Game/Turret Info Scene/locked_icon_32.png")
		rect.anchor_left = 0
		rect.anchor_top = 0
		rect.anchor_right = 1
		rect.anchor_bottom = 1
		rect.offset_left = 0
		rect.offset_top = 0
		rect.offset_right = 0
		rect.offset_bottom = 0
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(rect)
	hbox.add_child(btn)


func _build_shard_overlay() -> void:
	shardOverlay = GridContainer.new()
	shardOverlay.name = "ShardOverlay"
	shardOverlay.columns = 2
	shardOverlay.anchor_left = 0
	shardOverlay.anchor_top = 0
	shardOverlay.anchor_right = 1
	shardOverlay.anchor_bottom = 1
	shardOverlay.add_theme_constant_override("h_separation", 2)
	shardOverlay.add_theme_constant_override("v_separation", 2)
	shardOverlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shardOverlay.visible = false
	turretIcon.add_child(shardOverlay)

	shardSlots.clear()
	
	for i in range(4):
		var slot := Panel.new()
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var style := StyleBoxFlat.new()
		style.bg_color = Color(1, 1, 1, 0.0)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(1, 1, 1, 0.35)
		slot.add_theme_stylebox_override("panel", style)

		shardOverlay.add_child(slot)
		shardSlots.append(slot)

func _update_shard_overlay(turretID: Turret.TurretID, is_unlocked: bool) -> void:
	if is_unlocked:
		shardOverlay.visible = false
		turretIcon.material.set_shader_parameter("active_shards", 4) # Failsafe
		return

	shardOverlay.visible = true

	# 1. Get the turret's rarity and set the base color for the border
	var rarity: String = TurretManager.getTurretStat(turretID, "rarity")
	var rarity_color: Color = Color.WHITE 
	
	match rarity:
		"Common":     rarity_color = Color.DIM_GRAY
		"Rare":       rarity_color = Color.DARK_TURQUOISE
		"Super Rare": rarity_color = Color.MEDIUM_PURPLE
		"Legendary":  rarity_color = Color.GOLDENROD
		"Unseen":     rarity_color = Color.HOT_PINK

	# 2. Get exact number of shards owned
	var shards_owned: int = EconomyManager.get_turret_shards(turretID)
	var filled_slots: int = clampi(shards_owned, 0, 4)

	# Tell the shader exactly how many quadrants to light up!
	turretIcon.material.set_shader_parameter("active_shards", filled_slots)

	# 3. Loop through the 4 fixed slots and update their borders
	for i in range(4):
		var style: StyleBoxFlat = shardSlots[i].get_theme_stylebox("panel")
		
		if i < filled_slots:
			# Fully transparent background to reveal the turret's original artwork underneath
			style.bg_color = Color(1, 1, 1, 0.0) 
			# Keep the glowing colored border
			style.border_color = Color(rarity_color, 0.90) 
		else:
			# Empty slot styling
			style.bg_color = Color(1, 1, 1, 0.0)
			style.border_color = Color(1, 1, 1, 0.35)

func _on_turret_button_pressed(turretID: Turret.TurretID) -> void:
	statsBox.visible = false
	
	for child in infoLabelContainer.get_children():
		child.queue_free()
	
	soundPlayer.play()
	animationPlayer.play("InfoAppear")
	currentTurretID = turretID

	var is_unlocked := EconomyManager.is_turret_unlocked(turretID)

	turretIcon.texture = TurretManager.getTurretTexture(turretID)
	previewToggle.icon = TurretManager.getTurretTexture(turretID)
	previewToggle.button_pressed = false
	previewToggle.disabled = not is_unlocked

	turretIcon.material.set_shader_parameter("saturation", 1.0 if is_unlocked else 0.0)
	_update_shard_overlay(turretID, is_unlocked)
	
	turretDescriptionLabel.parse_bbcode(TurretManager.getTurretStat(turretID, "description"))

	turretNameLabel.text = TurretManager.getTurretStat(turretID, "name")
	
	typeLabel.text = TurretManager.getTurretStat(turretID, "type")

	var rarity: String = TurretManager.getTurretStat(turretID, "rarity")
	rarityLabel.text = rarity
	
	match rarity:
		"Common":     
			rarityLabel.label_settings.font_color = Color(Color.DIM_GRAY)
			shardImage.modulate = Color(1.0, 1.0, 1.0, 1.0)
			purchaseLabel2.text = "[center][font_size=20][color=white]Owned x" + str(EconomyManager.get_shards("common_turret")) + "[/color][/font_size][/center]"
			currentRarityShard = "common_turret"
		"Rare":       
			rarityLabel.label_settings.font_color = Color(Color.DARK_TURQUOISE)
			shardImage.modulate = Color("4a6cff")
			purchaseLabel2.text = "[center][font_size=20][color=white]Owned x" + str(EconomyManager.get_shards("rare_turret")) + "[/color][/font_size][/center]"
			currentRarityShard = "rare_turret"
		"Super Rare": 
			rarityLabel.label_settings.font_color = Color(Color.MEDIUM_PURPLE)
			shardImage.modulate = Color("6c01c1")
			purchaseLabel2.text = "[center][font_size=20][color=white]Owned x" + str(EconomyManager.get_shards("super_rare_turret")) + "[/color][/font_size][/center]"
			currentRarityShard = "super_rare_turret"
		"Legendary":  
			rarityLabel.label_settings.font_color = Color(Color.GOLDENROD)
			shardImage.modulate = Color("e3b11b")
			purchaseLabel2.text = "[center][font_size=20][color=white]Owned x" + str(EconomyManager.get_shards("legendary_turret")) + "[/color][/font_size][/center]"
			currentRarityShard = "legendary_turret"
		"Unseen":     
			rarityLabel.label_settings.font_color = Color(Color.HOT_PINK)
			shardImage.modulate = Color("fc5d7f")
			purchaseLabel2.text = "[center][font_size=20][color=white]Owned x" + str(EconomyManager.get_shards("unseen_turret")) + "[/color][/font_size][/center]"
			currentRarityShard = "unseen_turret"

	purchaseBox.show()
	purchaseLabel1.show()
	purchaseLabel2.show()

	levelTwoDescription.hide()
	levelThreeDescription.hide()
	levelTwoProgressBar.hide()
	levelThreeProgressBar.hide()
	
	levelTwoTexture.texture = lockedIcon
	levelThreeTexture.texture = lockedIcon

	if is_unlocked:
		purchaseBox.hide()
		purchaseLabel1.hide()
		purchaseLabel2.hide()
		statsBox.visible = true

		turretDescriptionLabel.add_theme_color_override("default_color", Color.WHITE)
		turretDescriptionLabel.add_theme_color_override("font_shadow_color", Color(0,0,0,0))
		turretDescriptionLabel.add_theme_color_override("font_outline_color", Color(0,0,0,0))
		turretDescriptionLabel.add_theme_constant_override("outline_size", 0)
		turretDescriptionLabel.add_theme_constant_override("shadow_offset_x", 0)
		turretDescriptionLabel.add_theme_constant_override("shadow_offset_y", 0)


		var turretLevel = XpManager.getCurrentLevel(turretID)

		# Always show and populate the descriptions so the player can preview future upgrades
		levelTwoDescription.show()
		levelThreeDescription.show()
		levelTwoDescription.parse_bbcode(TurretManager.getTurretStat(turretID, "levelTwo"))
		levelThreeDescription.parse_bbcode(TurretManager.getTurretStat(turretID, "levelThree"))

		if turretLevel == 1:
			# Level 1: Both 2 and 3 are locked (Set to 40% opacity)
			levelTwoTexture.modulate = Color(1.0, 1.0, 1.0, 0.4)
			levelThreeTexture.modulate = Color(1.0, 1.0, 1.0, 0.4)
			
			levelTwoProgressBar.show()
			levelThreeProgressBar.hide()
			levelTwoTexture.texture = lockedIcon
			levelThreeTexture.texture = lockedIcon
			
		elif turretLevel == 2:
			# Level 2: Level 2 is unlocked (100% opacity), Level 3 is locked (40% opacity)
			levelTwoTexture.modulate = Color(1.0, 1.0, 1.0, 1.0)
			levelThreeTexture.modulate = Color(1.0, 1.0, 1.0, 0.4)
			
			levelTwoProgressBar.hide()
			levelThreeProgressBar.show()
			levelTwoTexture.texture = unlockedIcon
			levelThreeTexture.texture = lockedIcon
			
		elif turretLevel == 3:
			# Level 3: Both are unlocked (100% opacity)
			levelTwoTexture.modulate = Color(1.0, 1.0, 1.0, 1.0)
			levelThreeTexture.modulate = Color(1.0, 1.0, 1.0, 1.0)
			
			levelThreeProgressBar.hide()
			levelTwoProgressBar.hide()
			levelTwoTexture.texture = unlockedIcon
			levelThreeTexture.texture = unlockedIcon

		var levelTwoMaxXp = XpManager.getMaxXp(TurretManager.getTurretStat(turretID,"rarity"),2)
		levelTwoProgressBar.max_value = levelTwoMaxXp
		levelThreeProgressBar.min_value = levelTwoMaxXp
		levelThreeProgressBar.max_value = XpManager.getMaxXp(TurretManager.getTurretStat(turretID,"rarity"),3)
		levelTwoProgressBar.value = XpManager.getCurrentXp(turretID)
		levelThreeProgressBar.value = XpManager.getCurrentXp(turretID)

		if toggleStatsButton.button_pressed:
			buildTurretStats(turretID)
		else:
			
			var properties: Array = TurretManager.getListOfProperties(turretID)
			createAndInsertPropertiesLabels(properties, turretID)

	createTooltips()


func _on_preview_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		turretIcon.visible = false
		var turretScene = TurretManager.loadTurretByID(currentTurretID).instantiate()
		var viewport_size = viewPort.size
		turretScene.position = Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0)
		viewPort.add_child(turretScene)
		viewportContainer.visible = true
	else:
		if viewPort.get_child_count(false) > 0:
			viewPort.get_child(0).queue_free()
		turretIcon.visible = true
		viewportContainer.visible = false


func createTooltips() -> void:
	turretDescriptionLabel.tooltip_text = ""
	var desc: String = turretDescriptionLabel.text
	if desc.contains("poison"):
		turretDescriptionLabel.tooltip_text += "Poison: Quickly ticks down health of enemies, but can't kill.\n"
	if desc.contains("curse"):
		turretDescriptionLabel.tooltip_text += "Curse: Increase the damage enemies take from all sources.\n"
	if desc.contains("ignite"):
		turretDescriptionLabel.tooltip_text += "Ignite: Sets enemies on fire, can kill.\n"
	if desc.contains("zombify"):
		turretDescriptionLabel.tooltip_text += "Zombify: Enemies turn into zombies, which take damage over time and infect other non zombified enemies.\n"
	if desc.contains("execute"):
		turretDescriptionLabel.tooltip_text += "Execute: Kills an enemy instantly.\n"


func createAndInsertPropertiesLabels(propertyList: Array, turretID: Turret.TurretID) -> void:
	for child in infoLabelContainer.get_children():
		child.queue_free()

	var turretStatsConfig = {
		"constructionTime": ["Construction Time: ", Color.GOLDENROD, "s"],
		"price": ["Scrap Cost: ", Color.GOLDENROD],
		"health": ["Health: ", Color.FUCHSIA],
		"armor": ["Armor: ", Color.GRAY],
		"damage": ["Damage: ", Color.RED],
		"reloadTime": ["Reload Time: ", Color.CORAL, "s"],
		"range": ["Range: ", Color.SKY_BLUE],
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
		"turnChance": ["Zombie Turn Chance: ", Color.SPRING_GREEN, "%"],
		"turnTime": ["Zombie Time: ", Color.GREEN_YELLOW, "s"],
		"knightDamage": ["Knight Damage: ", Color.SADDLE_BROWN],
		"knightHealth": ["Knight Health: ", Color.FOREST_GREEN],
		"bubbleApplyTime": ["Bubble Apply Time: ", Color.CORNFLOWER_BLUE, "s"],
		"bubbleHealth": ["Bubble Provided Health: ", Color.DEEP_SKY_BLUE]
	}

	# 1. Process Standard Properties
	for property in propertyList:
		if not turretStatsConfig.has(property):
			continue
		var config = turretStatsConfig[property]
		var prefix: String = config[0]
		var color: Color = config[1]
		var suffix: String = config[2] if config.size() > 2 else ""
		var value = TurretManager.getTurretStat(turretID, property)
		
		addStatLabel("%s%s%s" % [prefix, str(value), suffix], color, 0, true)

	# 2. Process Level-Specific Upgrades
	var current_level = XpManager.getCurrentLevel(turretID)
	if current_level < 2:
		return # Skip the rest if the turret isn't at least level 2
		
	match turretID:
		Turret.TurretID.ROYAL_TURRET:
			addStatLabel("Archer Summon Chance: %s%%" % TurretManager.getTurretStat(turretID, "archerSummonChance"), Color.LIGHT_CYAN, 0, true)
			addStatLabel("Max Archers: %s" % TurretManager.getTurretStat(turretID, "maxArchers"), Color.LIGHT_GRAY, 10)
			addStatLabel("Archer Health: %s" % TurretManager.getMinionStat(Minion.MinionID.ARCHER, "health"), Color.LIGHT_GREEN, 10)
			addStatLabel("Archer Damage: %s" % TurretManager.getMinionStat(Minion.MinionID.ARCHER, "damage"), Color.LIGHT_CORAL, 10)
			
			if current_level >= 3:
				addStatLabel("Bard Summon Chance: %s%%" % TurretManager.getTurretStat(turretID, "bardSummonChance"), Color.LIGHT_CYAN, 10)
				addStatLabel("Max Bards: %s" % TurretManager.getTurretStat(turretID, "maxBards"), Color.LIGHT_GRAY, 10)
				addStatLabel("Bard Health: %s" % TurretManager.getMinionStat(Minion.MinionID.BARD, "health"), Color.LIGHT_GREEN, 10)
				addStatLabel("Bard Heal: %s" % TurretManager.getMinionStat(Minion.MinionID.BARD, "healAmount"), Color.MEDIUM_SEA_GREEN, 10)

		Turret.TurretID.FLAME_TURRET:
			addStatLabel("Explosion Radius: %s" % TurretManager.getTurretStat(turretID, "flameExplosionRange"), Color.ROSY_BROWN, 10)
			if current_level >= 3:
				addStatLabel("Ignition Rounds Time: %ss" % TurretManager.getTurretStat(turretID, "ignitionRoundsTime"), Color.LIGHT_CORAL, 10)

		Turret.TurretID.FIREWORK_TURRET:
			addStatLabel("Ignite Damage: %s" % TurretManager.getTurretStat(turretID, "burnDamage"), Color.RED, 10)
			addStatLabel("Ignite Time: %s" % TurretManager.getTurretStat(turretID, "burnTime"), Color.INDIAN_RED, 10)
			if current_level >= 3:
				addStatLabel("Refund Chance: %s%%" % TurretManager.getTurretStat(turretID, "refundChance"), Color.DARK_TURQUOISE, 10)

		Turret.TurretID.REAPER_TURRET:
			addStatLabel("Chance Increase: %s%%" % TurretManager.getTurretStat(turretID, "executionChanceIncrease"), Color.DARK_GRAY, 10)

		Turret.TurretID.SPIDER_TURRET:
			addStatLabel("Web Chance: %s%%" % TurretManager.getTurretStat(turretID, "webChance"), Color.WHITE, 0, true)
			addStatLabel("Web Duration: %ss" % TurretManager.getTurretStat(turretID, "webDuration"), Color.LIGHT_GRAY, 0, true)

		Turret.TurretID.TESLA_TURRET:
			addStatLabel("Stun Time: %ss" % TurretManager.getTurretStat(turretID, "stunTime"), Color.DARK_GRAY, 0, true)
			if current_level >= 3:
				addStatLabel("Chain Range: %s" % TurretManager.getTurretStat(turretID, "chainRange"), Color.CORNFLOWER_BLUE, 0, true)

		Turret.TurretID.SEISMIC_TURRET:
			addStatLabel("Reload Damage: %s" % TurretManager.getTurretStat(turretID, "reloadShockwaveDamage"), Color.SADDLE_BROWN, 0, true)
			addStatLabel("Reload Tick Time: %s" % TurretManager.getTurretStat(turretID, "reloadShockwaveTickTime"), Color.ROSY_BROWN, 0, true)
			if current_level >= 3:
				addStatLabel("Chain Range: %s" % TurretManager.getTurretStat(turretID, "chainRange"), Color.SANDY_BROWN, 0, true)

		Turret.TurretID.GOLD_MINE_TURRET:
			addStatLabel("Extra Money: $%s" % TurretManager.getTurretStat(turretID, "extraGold"), Color.GOLDENROD, 0, true)
			addStatLabel("Extra Money Chance: %s%%" % TurretManager.getTurretStat(turretID, "extraGoldChance"), Color.PALE_GOLDENROD, 0, true)
			if current_level >= 3:
				addStatLabel("Golden Buff Kill Chance: %s%%" % TurretManager.getTurretStat(turretID, "extraGoldKillChance"), Color.GOLDENROD, 0, true)

		Turret.TurretID.SENTRY_TURRET:
			addStatLabel("Idle Bullets Reloaded: %s" % TurretManager.getTurretStat(turretID, "notFiringReloadBullets"), Color.DIM_GRAY, 0, true)
			if current_level >= 3:
				addStatLabel("Shooting Bullets Reloaded: %s" % TurretManager.getTurretStat(turretID, "firingReloadBullets"), Color.LIGHT_GRAY, 0, true)



# Helper function to generate labels cleanly
func addStatLabel(text: String, color: Color, font_size: int = 0, autowrap: bool = false) -> void:
	var label = Label.new()
	var settings = turretLabel.duplicate()
	settings.font_color = color
	label.label_settings = settings
	label.text = text

	if font_size > 0:
		label.add_theme_font_size_override("font_size", font_size)

	if autowrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.custom_minimum_size = Vector2(278, 0)
		label.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND

	infoLabelContainer.add_child(label)

func appendXpLabel(turretID: Turret.TurretID) -> void:
	var xpValue = XpManager.getCurrentXp(turretID)
	
	var label = Label.new()
	var settings = turretLabel.duplicate()
	
	# You can change this color to whatever fits your UI theme
	settings.font_color = Color.AQUAMARINE 
	
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.custom_minimum_size = Vector2(278, 0)
	label.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	
	# Formats the XP value nicely using your existing formatNumber function
	label.text = "XP: %s" % str(formatNumber(int(xpValue))) 
	label.label_settings = settings
	
	infoLabelContainer.add_child(label)

func buildTurretStats(turretID: Turret.TurretID) -> void:
	for child in infoLabelContainer.get_children():
		child.queue_free()

	var statDisplayConfig = {
		"kills": ["Kills: ", Color.CRIMSON],
		"damage_dealt": ["Damage Dealt: ", Color.RED],
		"damage_taken": ["Damage Taken: ", Color.DARK_RED],
		"deaths": ["Deaths: ", Color.DIM_GRAY],
		"placed": ["Times Placed: ", Color.LIGHT_GRAY],
		"turrets_energized": ["Turrets Energized: ", Color.DARK_ORCHID],
		"enemies_executed": ["Enemies Executed: ", Color.BLACK],
		"enemies_poisoned": ["Enemies Poisoned: ", Color.MEDIUM_SPRING_GREEN],
		"gold_produced": ["Gold Produced: $", Color.GOLD],
		"enemies_cursed": ["Enemies Cursed: ", Color.MEDIUM_PURPLE],
		"enemies_zombified": ["Enemies Zombified: ", Color.SPRING_GREEN],
		"health_healed": ["Health Healed: ", Color.GREEN_YELLOW],
		"bubbles_provided": ["Bubbles Provided: ", Color.DEEP_SKY_BLUE]
	}

	var stats: Dictionary = StatManager.getTurretStats(turretID)

	for stat_key in stats.keys():
		var value = stats[stat_key]
		var prefix: String
		var color: Color

		if statDisplayConfig.has(stat_key):
			prefix = statDisplayConfig[stat_key][0]
			color = statDisplayConfig[stat_key][1]
		else:
			prefix = stat_key.capitalize() + ": "
			color = Color.WHITE

		var label = Label.new()
		var settings = turretLabel.duplicate()
		settings.font_color = color
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.custom_minimum_size = Vector2(278, 0)
		label.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
		label.text = "%s%s" % [prefix, str(formatNumber(int(value)))]
		label.label_settings = settings
		infoLabelContainer.add_child(label)

	appendXpLabel(turretID)

func _on_turret_info_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Loadout.tscn")

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


func _on_stats_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		buildTurretStats(currentTurretID)
	else:
		var properties: Array = TurretManager.getListOfProperties(currentTurretID)
		createAndInsertPropertiesLabels(properties, currentTurretID)
	infoLabelContainer.show()


func _on_shard_button_pressed() -> void:
	if EconomyManager.get_shards(currentRarityShard) > 0:
		var particle = load("res://Party Horse!!!!!!/cpu_particles_2d.tscn")
		particle = particle.instantiate()
		particle.global_position = turretIcon.global_position
		particle.emitting = true
		particle.global_position.x += 150
		particle.global_position.y += 100
		$"../..".add_child(particle)
		SoundManager.playPieceUnlockedSound()
		var unlocked = false
		EconomyManager.add_turret_shards(currentTurretID,1)
		EconomyManager.spend_shards(currentRarityShard,1)
		if EconomyManager.get_turret_shards(currentTurretID) >= 4:
			EconomyManager.unlock_turret(currentTurretID)
			unlocked = true
			_on_turret_button_pressed(currentTurretID)
			for child in hbox.get_children():
				child.queue_free()
			for rarity in ["Common", "Rare", "Super Rare", "Legendary", "Unseen"]:
				for turretID in TurretManager.ALL_TURRETS:
					if TurretManager.getTurretStat(turretID, "rarity") == rarity:
						add_turret_button(turretID)
		EconomyManager.save_economy()
		_update_shard_overlay(currentTurretID,unlocked)
		purchaseLabel2.text = "[center][font_size=20][color=white]Owned x" + str(EconomyManager.get_shards(currentRarityShard)) + "[/color][/font_size][/center]"
	else:
		print("no")


func _on_turret_info_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Main Menu.tscn")
