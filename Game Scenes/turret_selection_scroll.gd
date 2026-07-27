extends Control

@onready var scroll = $ScrollContainer
@onready var hbox = $ScrollContainer/HBoxContainer
@onready var bringingGrid = $"../BringingGrid"
@onready var preview = $"../SubViewportContainer/SubViewport/TurretPreview"
@onready var turretTittleLabel = $"../../TurretTitle"
@onready var typeLabel = $"../../TypeLabel"
@onready var launchLabel = $"../../LaunchLabel"
@onready var launchButton = $"../BeginButton"

var broughtArray: Array = []
var player_ready_states: Dictionary = {}
var is_multiplayer: bool = false
var is_ready: bool = false
var has_started: bool = false
var has_triggered_start: bool = false

# Variables to handle the smooth scrolling tween
var target_scroll: float = 0.0
var scroll_tween: Tween

func _ready() -> void:
	#SoundManager.playLoadoutMusic()
	#difSlider.value = GameManager.difficultySave
	
	#scroll.custom_minimum_size = Vector2(700, 150)
	
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	
	scroll.gui_input.connect(_on_scroll_gui_input)

	for rarity in ["Common", "Rare", "Super Rare", "Legendary", "Unseen"]:
		for turret in TurretManager.unlockedTurrets:
			if TurretManager.getTurretStat(turret, "rarity") == rarity:
				add_turret_button(turret)

	is_multiplayer = GameManager.VSmode

	if is_multiplayer:
		# <- Reset lobby state so _process doesn't instantly trigger
		if SteamManager.is_host():
			Steam.setLobbyData(SteamManager.current_lobby_id, "state", "waiting")

	if is_multiplayer:
		for member in SteamManager.get_lobby_members():
			player_ready_states[member["steam_id"]] = false


func add_turret_button(turretID):
	if EconomyManager.is_turret_unlocked(turretID):
		var btn = Button.new()
		btn.icon = TurretManager.getTurretTexture(turretID)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_turret_button_pressed.bind(btn, turretID))
		
		# Connect the hover signal to the new preview function
		btn.mouse_entered.connect(_on_button_hovered.bind(turretID))
		
		btn.mouse_exited.connect(_on_button_exited)
		
		hbox.add_child(btn)


func add_remove_button(turretID):
	var btn = Button.new()
	btn.icon = TurretManager.getTurretTexture(turretID)
	
	btn.flat = true 
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER 
	
	btn.custom_minimum_size = Vector2(24, 24)
	btn.expand_icon = true
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	btn.mouse_entered.connect(func(): btn.modulate = Color(1.5, 1.5, 1.5, 1.0))

	btn.mouse_exited.connect(func(): btn.modulate = Color.WHITE)
	
	btn.pressed.connect(_on_remove_button_pressed.bind(btn, turretID))
	
	btn.mouse_entered.connect(_on_button_hovered.bind(turretID))
	
	btn.mouse_exited.connect(_on_button_exited)
	
	bringingGrid.add_child(btn)


func _on_button_exited() -> void:
	if preview and preview.has_method("clear"):
		preview.clear()
		
	turretTittleLabel.text = ""
	typeLabel.text = ""

func _on_button_hovered(turretID) -> void:

	if preview and preview.has_method("buildPreview"):
		preview.buildPreview(turretID)
	turretTittleLabel.text = TurretManager.getTurretStat(turretID,"name")
	typeLabel.text = TurretManager.getColorRawType(turretID)


func _on_turret_button_pressed(btn, turretID):
	if broughtArray.size() < 10:
		btn.queue_free()
		broughtArray.append(turretID)
		add_remove_button(turretID)
		launchLabel.show()
		launchButton.show()


func _on_remove_button_pressed(btn, turretID):
	btn.queue_free()
	add_turret_button(turretID)
	broughtArray.erase(turretID)
	if broughtArray.size() <= 0:
		launchLabel.hide()
		launchButton.hide()


func _on_turret_info_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Turret Info.tscn")


func _on_begin_button_pressed() -> void:
	if is_multiplayer:
		return
	SoundManager.stopLoadoutMusic()
	#get_tree().get_first_node_in_group("CityCanvas").hide()
	GameManager.turretsBrought = broughtArray.duplicate()
	for item in GameManager.turretsBrought:
		GameManager.turretTempLevels[item] = 0
	SoundManager.playStartButtonSound()
	$"../../AnimationPlayer".play("Launch")
	PopupManager.clearCaptainPopups()
	launchButton.disabled = true



func _on_scroll_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			
			scroll.accept_event()
			
			if not scroll_tween or not scroll_tween.is_running():
				target_scroll = scroll.scroll_horizontal
				
			var scroll_amount = 150 # Adjust this to change how fast/far one wheel click moves
			
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				target_scroll = max(0, target_scroll - scroll_amount)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var max_scroll = max(0, hbox.size.x - scroll.size.x)
				target_scroll = min(max_scroll, target_scroll + scroll_amount)
				
			if scroll_tween:
				scroll_tween.kill()
				
			scroll_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			scroll_tween.tween_property(scroll, "scroll_horizontal", target_scroll, 0.4)
