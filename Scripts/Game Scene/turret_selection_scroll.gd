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
@onready var lockedRequiredText = $"../LevelContainer/LevelThreeTexture/RequiredText"
@onready var animationPlayer = $"../AnimationPlayer"
@onready var turretLabel = preload("res://Labels/turret_info_label.tres")
@onready var soundPlayer = $"../../TurretSelectSound"

var currentTurretID: Turret.TurretID = Turret.TurretID.NONE


func _idToName(turretID: Turret.TurretID) -> String:
	return Turret.TurretID.keys()[turretID].to_lower()


func _ready() -> void:
	GameManager.previewMode = true
	scroll.custom_minimum_size = Vector2(700, 150)

	for rarity in ["Common", "Rare", "Super Rare", "Legendary", "Unseen"]:
		for turretID in TurretManager.unlockedTurrets:
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
	hbox.add_child(btn)


func _on_turret_button_pressed(turretID: Turret.TurretID) -> void:
	soundPlayer.play()
	animationPlayer.play("InfoAppear")
	currentTurretID = turretID

	var name := _idToName(turretID)

	turretIcon.texture = TurretManager.getTurretTexture(turretID)
	previewToggle.icon = TurretManager.getTurretTexture(turretID)
	previewToggle.button_pressed = false

	turretNameLabel.text = TurretManager.getTurretStat(turretID, "name")
	turretDescriptionLabel.text = TurretManager.getTurretStat(turretID, "description")
	typeLabel.text = TurretManager.getTurretStat(turretID, "type")

	var rarity: String = TurretManager.getTurretStat(turretID, "rarity")
	rarityLabel.text = rarity

	var turretLevel = TurretManager.getTurretLevel(turretID)

	if turretLevel == 1:
		levelTwoDescription.hide()
		levelThreeDescription.hide()
		levelTwoProgressBar.show()
		levelThreeProgressBar.hide()
		lockedRequiredText.show()
		levelTwoTexture.texture = lockedIcon
		levelThreeTexture.texture = lockedIcon
	elif turretLevel == 2:
		levelTwoDescription.show()
		levelThreeDescription.hide()
		levelTwoProgressBar.hide()
		levelThreeProgressBar.show()
		lockedRequiredText.hide()
		levelTwoTexture.texture = unlockedIcon
		levelThreeTexture.texture = lockedIcon
	elif turretLevel == 3:
		levelTwoDescription.show()
		levelThreeDescription.show()
		levelThreeProgressBar.hide()
		levelTwoProgressBar.hide()
		lockedRequiredText.hide()
		levelTwoTexture.texture = unlockedIcon
		levelThreeTexture.texture = unlockedIcon

	match rarity:
		"Common":     rarityLabel.label_settings.font_color = Color(Color.DIM_GRAY)
		"Rare":       rarityLabel.label_settings.font_color = Color(Color.DARK_TURQUOISE)
		"Super Rare": rarityLabel.label_settings.font_color = Color(Color.MEDIUM_PURPLE)
		"Legendary":  rarityLabel.label_settings.font_color = Color(Color.GOLDENROD)
		"Unseen":     rarityLabel.label_settings.font_color = Color(Color.HOT_PINK)

	var levelTwoMaxXp = TurretManager.getMaxXp(rarity, 2)
	levelTwoProgressBar.max_value = levelTwoMaxXp
	levelThreeProgressBar.min_value = levelTwoMaxXp
	levelThreeProgressBar.max_value = TurretManager.getMaxXp(rarity, 3)
	levelTwoProgressBar.value = TurretManager.getTurretXp(turretID)
	levelThreeProgressBar.value = TurretManager.getTurretXp(turretID)

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
		"knightHealth": ["Knight Health: ", Color.FOREST_GREEN],
		"bubbleApplyTime": ["Bubble Apply Time: ", Color.CORNFLOWER_BLUE, "s"],
		"bubbleHealth": ["Bubble Provided Health: ", Color.DEEP_SKY_BLUE]
	}

	for property in propertyList:
		if not turretStatsConfig.has(property):
			continue
		var config = turretStatsConfig[property]
		var prefix: String = config[0]
		var color: Color = config[1]
		var suffix: String = config[2] if config.size() > 2 else ""
		var value = TurretManager.getTurretStat(turretID, property)

		var label = Label.new()
		var settings = turretLabel.duplicate()
		settings.font_color = color
		label.label_settings = settings
		label.text = "%s%s%s" % [prefix, str(value), suffix]
		infoLabelContainer.add_child(label)


func _on_turret_info_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Loadout.tscn")
