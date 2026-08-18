extends Control

@onready var scroll = $ScrollContainer
@onready var hbox = $ScrollContainer/HBoxContainer
@onready var bringingGrid = $"../BringingGrid"
@onready var preview = $"../SubViewportContainer/SubViewport/TurretPreview"
@onready var turretTittleLabel = $"../../TurretTitle"
@onready var typeLabel = $"../../TypeLabel"
@onready var launchLabel = $"../../LaunchLabel"
@onready var launchButton = $"../BeginButton"

@onready var readyButton = $"../ReadyButton"
@onready var readyLabel = $"../../ReadyLabel"

var broughtArray: Array = []
var player_ready_states: Dictionary = {}
var is_ready: bool = false
var has_started: bool = false
var has_triggered_start: bool = false

# Variables to handle the smooth scrolling tween
var target_scroll: float = 0.0
var scroll_tween: Tween

func _ready() -> void:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	
	scroll.gui_input.connect(_on_scroll_gui_input)

	for rarity in ["Common", "Rare", "Super Rare", "Legendary", "Unseen"]:
		for turret in TurretManager.unlockedTurrets:
			if TurretManager.getTurretStat(turret, "rarity") == rarity:
				add_turret_button(turret)

	if GameManager.VSmode:
		if SteamManager.lobbyID != 0 and SteamManager.check_player_count() > 0:
			if Steam.getLobbyOwner(SteamManager.lobbyID) == SteamManager.steam_id:
				Steam.setLobbyData(SteamManager.lobbyID, "state", "waiting")
				
		for member in Steam.getNumLobbyMembers(SteamManager.lobbyID):
			var mem_id = Steam.getLobbyMemberByIndex(SteamManager.lobbyID, member)
			player_ready_states[mem_id] = false

func add_turret_button(turretID):
	if EconomyManager.is_turret_unlocked(turretID):
		var btn = Button.new()
		btn.icon = TurretManager.getTurretTexture(turretID)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_turret_button_pressed.bind(btn, turretID))
		
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
		
		_sync_loadout_to_steam()
		
		if not GameManager.VSmode:
			launchLabel.show()
			launchButton.show()
		else:
			readyButton.show()
			readyLabel.show()


func _on_remove_button_pressed(btn, turretID):
	btn.queue_free()
	add_turret_button(turretID)
	broughtArray.erase(turretID)
	
	_sync_loadout_to_steam()
	
	if broughtArray.size() <= 0:
		launchLabel.hide()
		launchButton.hide()


func _sync_loadout_to_steam():
	# Only block this if we are not actually in a multiplayer lobby
	if SteamManager.lobbyID == 0:
		return

	var turret_names: Array[String] = []
	for turret_id in broughtArray:
		turret_names.append(TurretManager.get_turret_string(turret_id))

	SteamManager.set_loadout_slot("loadout_list", ",".join(turret_names))


func _on_turret_info_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Turret Info.tscn")


func _on_begin_button_pressed() -> void:
	if GameManager.VSmode:
		return
		
	SoundManager.stopMusic()
	GameManager.turretsBrought = broughtArray.duplicate()
	for item in GameManager.turretsBrought:
		GameManager.turretTempLevels[item] = 0
	SoundManager.playStartButtonSound()
	$"../../AnimationPlayer".play("Launch")
	PopupManager.clearCaptainPopups()
	launchButton.disabled = true

var is_local_ready: bool = false

func _on_ready_button_pressed() -> void:
	is_local_ready = !is_local_ready
	
	if is_local_ready:
		readyLabel.text = "[steel]Readied Up[/steel]"
		readyButton.modulate = Color.LAWN_GREEN
		
		if SteamManager.lobbyID != 0:
			SteamManager.set_loadout_slot("is_ready", "true")
	else:
		readyLabel.text = "[steel]Ready[/steel]" 
		readyButton.modulate = Color.WHITE 
		
		if SteamManager.lobbyID != 0:
			SteamManager.set_loadout_slot("is_ready", "false")


func _on_scroll_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			
			scroll.accept_event()
			
			if not scroll_tween or not scroll_tween.is_running():
				target_scroll = scroll.scroll_horizontal
				
			var scroll_amount = 150 
			
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				target_scroll = max(0, target_scroll - scroll_amount)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var max_scroll = max(0, hbox.size.x - scroll.size.x)
				target_scroll = min(max_scroll, target_scroll + scroll_amount)
				
			if scroll_tween:
				scroll_tween.kill()
				
			scroll_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			scroll_tween.tween_property(scroll, "scroll_horizontal", target_scroll, 0.4)
