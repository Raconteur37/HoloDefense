extends CanvasLayer

var turretContainer

@onready var leftColumn = $Panel/ScrollContainer/HBoxContainer/LeftColumn
@onready var rightColumn = $Panel/ScrollContainer/HBoxContainer/RightColumn
@onready var scroll = $Panel/ScrollContainer
@onready var hbox = $Panel/ScrollContainer/HBoxContainer

var turretPlacement = 0

func _ready() -> void:
	
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(100, 300)

	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

	leftColumn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rightColumn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	#leftColumn.custom_minimum_size = Vector2(150, 0)
	#rightColumn.custom_minimum_size = Vector2(150, 0)
	
	
	for turret in TurretManager.unlockedTurrets:
		turretPlacement += 1
		add_turret_button(turret)

func add_turret_button(turretName : String):
	var btn = Button.new()
	btn.name = turretName
	btn.icon = TurretManager.findTurretTexture(turretName)
	btn.tooltip_text = turretName
	btn.pressed.connect(_on_turret_button_pressed.bind(turretName))
	if turretPlacement % 2 != 0:
		leftColumn.add_child(btn)
	else:
		rightColumn.add_child(btn)

func _on_turret_button_pressed(turretName: String):
	PlacementManager.selectTurret(turretName)
	# You can also store the selected ID, update visuals, etc.
