extends Control

var turretContainer

@onready var scroll = $Panel/ScrollContainer
@onready var hbox = $Panel/ScrollContainer/HBoxContainer

@onready var turretIcon = $"../TurretIcon"
@onready var turretNameLabel = $"../VBoxContainer2/TurretNameLabel"
@onready var turretDescriptionLabel = $"../LevelContainer/LevelOneTexture/RichTextLabel"
@onready var rarityLabel = $"../VBoxContainer2/RarityLabel"
@onready var typeLabel = $"../TypeLabel"

@onready var priceLabel = $"../VBoxContainer/Price/PriceLabel"

@onready var previewToggle = $"../PreviewButton"

@onready var viewportContainer = $"../SubViewportContainer"
@onready var viewPort = $"../SubViewportContainer/SubViewport"

@onready var levelTwoProgressBar = $"../LevelContainer/LevelTwoTexture/LevelTwoProgress"
@onready var levelTwoDescription = $"../LevelContainer/LevelTwoTexture/TurretDescriptionLabel"
@onready var levelThreeProgressBar = $"../LevelContainer/LevelThreeTexture/LevelThreeProgress"
@onready var levelThreeDescription = $"../LevelContainer/LevelThreeTexture/TurretDescriptionLabel"

@onready var levelTwoTexture = $"../LevelContainer/LevelTwoTexture"
@onready var levelThreeTexture = $"../LevelContainer/LevelThreeTexture"

@onready var unlockedIcon = load("res://Textures/UI/Turret Info/LevelOneInfo.png")
@onready var lockedIcon = load("res://Textures/UI/Turret Info/Locked.png")

@onready var lockedRequiredText = $"../LevelContainer/LevelThreeTexture/RequiredText"

@onready var animationPlayer = $"../AnimationPlayer"

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
	turretNameLabel.text = turretName
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

	priceLabel.text = "$" + str(TurretManager.getTurretStat(turretName,"price"))

	createTooltips()


func _on_preview_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		turretIcon.visible = false
		var turretScene = TurretManager.loadTurretByName(currentTurret).instantiate()
		turretScene.global_position.x = viewPort.size.x / 2
		turretScene.global_position.y = viewPort.size.y / 2
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
		turretDescriptionLabel.tooltip_text += "Execute: Kills an enemy instasnty.\n"
