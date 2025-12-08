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

@onready var unlockedIcon = load("res://Textures/UI/Turret Info/InfoPanel.png")
@onready var lockedIcon = load("res://Textures/UI/Turret Info/InfoPanel.png")

@onready var lockedRequiredText = $"../LevelContainer/LevelThreeTexture/RequiredText"

@onready var animationPlayer = $"../AnimationPlayer"

@onready var turretLabel = preload("res://Labels/turret_info_label.tres")

var turretXPData = {}

var currentTurret : String

func _ready() -> void:

	GameManager.previewMode = true

	#scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(700,150)

	#hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

	#for turret in TurretManager.allTurrets:
	#	add_turret_button(turret)

	# Sorted by rarity ascending
	for rarity in ["Common","Rare","Super Rare","Legendary","Unseen"]:
		for turret in TurretManager.allTurrets:
			if TurretManager.getTurretStat(turret,"rarity") == rarity:
				add_turret_button(turret)

	_on_turret_button_pressed("arrow_turret")

func add_turret_button(turretName : String):
	var btn = Button.new()
	btn.name = turretName
	btn.icon = TurretManager.findTurretTexture(turretName)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.tooltip_text = turretName
	btn.pressed.connect(_on_turret_button_pressed.bind(turretName))
	hbox.add_child(btn)

func _on_turret_button_pressed(turretName: String):
	animationPlayer.play("InfoAppear")
	turretIcon.texture = TurretManager.findTurretTexture(turretName)
	previewToggle.icon = TurretManager.findTurretTexture(turretName)
	currentTurret = turretName
	previewToggle.button_pressed = false
	turretNameLabel.text = TurretManager.getTurretStat(turretName,"name")
	turretDescriptionLabel.text = TurretManager.getTurretStat(turretName,"description")
	typeLabel.text = TurretManager.getTurretStat(turretName,"type")

	var rarity = TurretManager.getTurretStat(turretName,"rarity")
	rarityLabel.text = rarity

	var turretLevel = TurretManager.getTurretLevel(turretName)

	if turretLevel == 1:
		levelTwoDescription.hide()
		levelThreeDescription.hide()
		levelTwoProgressBar.show()
		levelThreeProgressBar.hide()
		lockedRequiredText.show()
		levelTwoTexture.texture = lockedIcon
		levelThreeTexture.texture = lockedIcon
	if turretLevel == 2:
		levelTwoDescription.show()
		levelThreeDescription.hide()
		levelTwoProgressBar.hide()
		levelThreeProgressBar.show()
		lockedRequiredText.hide()
		levelTwoTexture.texture = unlockedIcon
		levelThreeTexture.texture = lockedIcon
	if turretLevel == 3:
		levelTwoDescription.show()
		levelThreeDescription.show()
		levelThreeProgressBar.hide()
		levelTwoProgressBar.hide()
		lockedRequiredText.hide()
		levelTwoTexture.texture = unlockedIcon
		levelThreeTexture.texture = unlockedIcon

	if rarity == "Common":
		rarityLabel.label_settings.font_color = Color(Color.DIM_GRAY)
	if rarity == "Rare":
		rarityLabel.label_settings.font_color = Color(Color.DARK_BLUE)
	if rarity == "Super Rare":
		rarityLabel.label_settings.font_color = Color(Color.REBECCA_PURPLE)
	if rarity == "Legendary":
		rarityLabel.label_settings.font_color = Color(Color.GOLDENROD)
	if rarity == "Unseen":
		rarityLabel.label_settings.font_color = Color(Color.HOT_PINK)

	var levelTwoMaxXp = TurretManager.getMaxXp(rarity,2)
	levelTwoProgressBar.max_value = levelTwoMaxXp
	levelThreeProgressBar.min_value = levelTwoMaxXp
	levelThreeProgressBar.max_value = TurretManager.getMaxXp(rarity,3)

	levelTwoProgressBar.value = TurretManager.getTurretXp(turretName)
	levelThreeProgressBar.value = TurretManager.getTurretXp(turretName)

	#priceLabel.text = "$" + str(TurretManager.getTurretStat(turretName,"price"))
	var properties : Array = TurretManager.getListOfProperties(turretName)

	createAndInsertPropertiesLabels(properties,turretName)


	createTooltips()


func _on_preview_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		turretIcon.visible = false
		var turretScene = TurretManager.loadTurretByName(currentTurret).instantiate()
		var viewport_size = viewPort.size

		# Calculate the center point
		var center_x = viewport_size.x / 2.0
		var center_y = viewport_size.y / 2.0
		turretScene.position = Vector2(center_x, center_y)
		viewPort.add_child(turretScene)
		# Set the turret level based on config
		viewportContainer.visible = true
	else:
		if viewPort.get_child_count(false) > 0:
			viewPort.get_child(0).queue_free()
		turretIcon.visible = true
		viewportContainer.visible = false


func createTooltips():
	turretDescriptionLabel.tooltip_text = ""
	if turretDescriptionLabel.text.contains("poison"):
		turretDescriptionLabel.tooltip_text += "Poison: Quickly ticks down health of enemies, but can't kill.\n"
	if turretDescriptionLabel.text.contains("curse"):
		turretDescriptionLabel.tooltip_text += "Curse: Increase the damage enemies take from all sources.\n"
	if turretDescriptionLabel.text.contains("ignite"):
		turretDescriptionLabel.tooltip_text += "Ignite: Sets enemies on fire, can kill.\n"
	if turretDescriptionLabel.text.contains("zombify"):
		turretDescriptionLabel.tooltip_text += "Zombify: Enemies turn into zombies, which take damage over time and infect other non zombified enemies.\n"
	if turretDescriptionLabel.text.contains("execute"):
		turretDescriptionLabel.tooltip_text += "Execute: Kills an enemy instantly.\n"

func createAndInsertPropertiesLabels(propertyList,turretName):

	for child in infoLabelContainer.get_children():
		child.queue_free()

	print(propertyList)

	for item in propertyList:
		var label = Label.new()
		var custom_settings = turretLabel.duplicate()
		label.label_settings = custom_settings

		match item:

			"price":
				label.text = "Price: %s" % TurretManager.getTurretStat(turretName,item)
				custom_settings.font_color = Color.GOLDENROD
				infoLabelContainer.add_child(label)
			"damage":
				label.text = "Damage: %s" % TurretManager.getTurretStat(turretName,item)
				custom_settings.font_color = Color.FIREBRICK
				infoLabelContainer.add_child(label)
			"health":
				label.text = "Health: %s" % TurretManager.getTurretStat(turretName,item)
				custom_settings.font_color = Color.FUCHSIA
				infoLabelContainer.add_child(label)
			"armor":
				label.text = "Armor: %s" % TurretManager.getTurretStat(turretName,item)
				custom_settings.font_color = Color.GRAY
				infoLabelContainer.add_child(label)
			"reloadTime":
				label.text = "Reload Time: %ss" % TurretManager.getTurretStat(turretName,item)
				custom_settings.font_color = Color.KHAKI
				infoLabelContainer.add_child(label)
			"range":
				label.text = "Range: %s" % TurretManager.getTurretStat(turretName,item)
				custom_settings.font_color = Color.CORNFLOWER_BLUE
				infoLabelContainer.add_child(label)
			"projectileSpeed":
				label.text = "Projectile Speed: %s" % TurretManager.getTurretStat(turretName,item)
				custom_settings.font_color = Color.FOREST_GREEN
				infoLabelContainer.add_child(label)
			"constructionTime":
				label.text = "Construction Time: %ss" % TurretManager.getTurretStat(turretName,item)
				custom_settings.font_color = Color.BURLYWOOD
				infoLabelContainer.add_child(label)
			"poisonChance":
				label.text = "Poison Chance: " + str(TurretManager.getTurretStat(turretName,item)) + "%"
				custom_settings.font_color = Color.MEDIUM_SPRING_GREEN
				infoLabelContainer.add_child(label)
			"poisonDuration":
				label.text = "Poison Duration: %ss" % TurretManager.getTurretStat(turretName,item)
				custom_settings.font_color = Color.MEDIUM_SEA_GREEN
				infoLabelContainer.add_child(label)
			"poisonDamage":
				label.text = "Poison Damage: %s" % TurretManager.getTurretStat(turretName,item)
				custom_settings.font_color = Color.SPRING_GREEN
				infoLabelContainer.add_child(label)
			"curseDuration":
				label.text = "Curse Duration: %ss" % TurretManager.getTurretStat(turretName,item)
				custom_settings.font_color = Color.REBECCA_PURPLE
				infoLabelContainer.add_child(label)
			"curseDamageAmp":
				label.text = "Curse Damage Amp.: " + str(TurretManager.getTurretStat(turretName,item)) + "%"
				custom_settings.font_color = Color.WEB_PURPLE
				infoLabelContainer.add_child(label)
			"curseChance":
				label.text = "Curse Chance: " + str(TurretManager.getTurretStat(turretName,item)) + "%"
				custom_settings.font_color = Color.MEDIUM_PURPLE
				infoLabelContainer.add_child(label)
			"pierce":
				label.text = "Pierce: %s" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.PERU
				infoLabelContainer.add_child(label)
			"fireDamage":
				label.text = "Fire Damage: %s" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.RED
				infoLabelContainer.add_child(label)
			"fireTime":
				label.text = "Fire Duration: %ss" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.INDIAN_RED
				infoLabelContainer.add_child(label)
			"fireTickTime":
				label.text = "Fire Tick: %ss" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.ORANGE_RED
				infoLabelContainer.add_child(label)
			"maxBullets":
				label.text = "Bullet Capacity: %s" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.WEB_GRAY
				infoLabelContainer.add_child(label)
			"shotTime":
				label.text = "Fire Rate: %ss" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.LIGHT_GRAY
				infoLabelContainer.add_child(label)
			"healingTime":
				label.text = "Healing Time: %ss" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.FOREST_GREEN
				infoLabelContainer.add_child(label)
			"healingAmount":
				label.text = "Healing Amount: %s" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.LAWN_GREEN
				infoLabelContainer.add_child(label)
			"energizeTime":
				label.text = "Energize Time: %ss" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.BLUE_VIOLET
				infoLabelContainer.add_child(label)
			"maxTurretsEnergized":
				label.text = "Max Turrets Energized: %s" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.DARK_ORCHID
				infoLabelContainer.add_child(label)
			"energizerDamageBuff":
				label.text = "Damage Buff: " + str(TurretManager.getTurretStat(turretName,item)) + "%"
				custom_settings.font_color = Color.MEDIUM_PURPLE
				infoLabelContainer.add_child(label)
			"energizerProjectileSpeedBuff":
				label.text = "Projectile Speed Buff: " + str(TurretManager.getTurretStat(turretName,item)) + "%"
				custom_settings.font_color = Color.MEDIUM_PURPLE
				infoLabelContainer.add_child(label)
			"energizerAttackRangeBuff":
				label.text = "Range Buff: " + str(TurretManager.getTurretStat(turretName,item)) + "%"
				custom_settings.font_color = Color.MEDIUM_PURPLE
				infoLabelContainer.add_child(label)
			"energizerReloadTimeBuff":
				label.text = "Reload Time Buff: " + str(TurretManager.getTurretStat(turretName,item)) + "%"
				custom_settings.font_color = Color.MEDIUM_PURPLE
				infoLabelContainer.add_child(label)
			"summonTime":
				label.text = "Summon Time: %s" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.SANDY_BROWN
				infoLabelContainer.add_child(label)
			"maxKnights":
				label.text = "Max Knights: %s" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.SADDLE_BROWN
				infoLabelContainer.add_child(label)
			"executionChance":
				label.text = "Execution Chance: " + str(TurretManager.getTurretStat(turretName,item)) + "%"
				custom_settings.font_color = Color.BLACK
				infoLabelContainer.add_child(label)
			"explosionDamage":
				label.text = "Explosion Damage: %s" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.CHOCOLATE
				infoLabelContainer.add_child(label)
			"explosionRadius":
				label.text = "Explosion Radius: %s" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.ROSY_BROWN
				infoLabelContainer.add_child(label)
			"shotDelay":
				label.text = "Shot Delay: %ss" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.ROYAL_BLUE
				infoLabelContainer.add_child(label)
			"baseGoldProduced":
				label.text = "Gold Produced: %s" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.GOLD
				infoLabelContainer.add_child(label)
			"generateTime":
				label.text = "Gold Generate Time: %ss" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.DARK_GOLDENROD
				infoLabelContainer.add_child(label)
			"turnChance":
				label.text = "Turn Chance: " + str(TurretManager.getTurretStat(turretName,item)) + "%"
				custom_settings.font_color = Color.WEB_GREEN
				infoLabelContainer.add_child(label)
			"turnTime":
				label.text = "Zombie Time: %ss" % str(TurretManager.getTurretStat(turretName,item))
				custom_settings.font_color = Color.SEA_GREEN
				infoLabelContainer.add_child(label)
