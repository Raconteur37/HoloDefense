extends Control

var turretContainer

@onready var scroll = $Panel/ScrollContainer
@onready var hbox = $Panel/ScrollContainer/HBoxContainer

@onready var turretIcon = $"../TurretIcon"
@onready var turretNameLabel = $"../VBoxContainer2/TurretNameLabel"
@onready var turretDescriptionLabel = $"../TurretDescriptionLabel"
@onready var rarityLabel = $"../VBoxContainer2/RarityLabel"
@onready var typeLabel = $"../TypeLabel"

@onready var priceLabel = $"../VBoxContainer/HBoxContainer/PriceLabel"

var turretData = {}

func _ready() -> void:

	#scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(700,150)

	#hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

	for turret in TurretManager.allTurrets:
		add_turret_button(turret)

	var file = FileAccess.open("res://Config/Turret Info.json",FileAccess.READ)
	turretData = JSON.parse_string(file.get_as_text())

	# Sorted by rarity ascending
	#for rarity in ["Common","Rare","Super Rare","Legendary","Unseen"]:
	#	for turret in TurretManager.allTurrets:
	#		if turretData[turret].rarity == rarity:
	#			add_turret_button(turret)

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
	turretIcon.texture = TurretManager.findTurretTexture(turretName)
	turretNameLabel.text = turretName
	turretDescriptionLabel.text = turretData[turretName].description
	typeLabel.text = turretData[turretName].type

	var rarity = turretData[turretName].rarity
	rarityLabel.text = rarity
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


	priceLabel.text = "$" + str(turretData[turretName].price)
