extends Control

@onready var scroll = $TurretSelectionScroll/ScrollContainer
@onready var hbox = $TurretSelectionScroll/ScrollContainer/HBoxContainer
@onready var bringingGrid = $BringingGrid
@onready var difSlider = $VSlider
@onready var difLabel = $DifficultyLabel
@onready var beginButton = $BeginButton

var broughtArray : Array = []

func _ready() -> void:

	#scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(700,150)

	#hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

	#for turret in TurretManager.allTurrets:
	#	add_turret_button(turret)

	# Sorted by rarity ascending
	for rarity in ["Common","Rare","Super Rare","Legendary","Unseen"]:
		for turret in TurretManager.unlockedTurrets:
			if TurretManager.getTurretStat(turret,"rarity") == rarity:
				add_turret_button(turret)
	beginButton.hide()

func add_turret_button(turretID):
	var btn = Button.new()
	btn.icon = TurretManager.getTurretTexture(turretID)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(_on_turret_button_pressed.bind(btn,turretID))
	hbox.add_child(btn)

func add_remove_button(turretID):
	var btn = Button.new()
	btn.icon = TurretManager.getTurretTexture(turretID)
	#btn.custom_minimum_size = Vector2(500, 500)
	btn.custom_minimum_size = Vector2(150, 150)
	btn.expand_icon = true
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(_on_remove_button_pressed.bind(btn,turretID))
	bringingGrid.add_child(btn)

func _on_turret_button_pressed(btn,turretID):
	if broughtArray.size() < 10:
		btn.queue_free()
		broughtArray.append(turretID)
		add_remove_button(turretID)
	if broughtArray.size() >= 10:
		beginButton.show()

func _on_remove_button_pressed(btn,turretID):
	btn.queue_free()
	add_turret_button(turretID)
	broughtArray.erase(turretID)
	beginButton.hide()


func _on_v_slider_value_changed(value: float) -> void:
	if value >= 1 and value <= 4:
		difLabel.text = "[pulse color=green height=0.5 freq=0.3][font_size=30]Difficulty: " + str(int(value)) + "[/font_size][/pulse]"
	if value >= 5 and value <= 8:
		difLabel.text = "[pulse color=yellow height=0.5 freq=0.3][font_size=30]Difficulty: " + str(int(value)) + "[/font_size][/pulse]"
	if value >= 9:
		difLabel.text = "[pulse color=red height=0.5 freq=0.3][font_size=30]Difficulty: " + str(int(value)) + "[/font_size][/pulse]"
	WaveManager.currentDifficulty = int(value)


func _on_begin_button_pressed() -> void:
	GameManager.turretsBrought = broughtArray.duplicate()
	for item in GameManager.turretsBrought:
		GameManager.turretTempLevels[item] = 0
	#print(GameManager.turretsBrought)
	get_tree().change_scene_to_file("res://Game Scenes/Game.tscn")
