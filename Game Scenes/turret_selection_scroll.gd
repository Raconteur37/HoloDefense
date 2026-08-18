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

var _poll_accumulator: float = 0.0
const POLL_INTERVAL: float = 0.5

# --- TEMP DEBUG OVERLAY ---
# Flip to false (or delete this block + its calls) once the transition bug
# is found. Shows local ready-state + trigger status on-screen so you and
# your friend can each just look at your own screen / screenshot it after
# a test run, instead of needing console access on a Steam build.
const DEBUG_OVERLAY: bool = true
var _debug_label: Label

func _create_debug_overlay() -> void:
	_debug_label = Label.new()
	_debug_label.add_theme_color_override("font_color", Color.YELLOW)
	_debug_label.add_theme_font_size_override("font_size", 16)
	_debug_label.position = Vector2(10, 10)
	_debug_label.z_index = 4096
	_debug_label.top_level = true
	_debug_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_debug_label)

func _update_debug_overlay() -> void:
	if not _debug_label:
		return
	var is_host = SteamManager.lobbyID != 0 and Steam.getLobbyOwner(SteamManager.lobbyID) == SteamManager.steam_id
	var txt = "steam_id=%d  is_host=%s\nvsmode=%s  is_vs_match=%s\ntriggered=%s\n" % [
		SteamManager.steam_id, str(is_host),
		str(GameManager.VSmode), str(_is_vs_match()),
		str(has_triggered_start)
	]
	txt += "ready_states (%d/%d expected):\n" % [player_ready_states.size(), SteamManager.check_player_count()]
	for pid in player_ready_states:
		txt += "  %d: %s\n" % [pid, str(player_ready_states[pid])]
	_debug_label.text = txt
# --- END TEMP DEBUG OVERLAY ---


func _ready() -> void:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	
	scroll.gui_input.connect(_on_scroll_gui_input)

	launchButton.hide()
	launchLabel.hide()
	readyButton.hide()
	readyLabel.hide()

	for rarity in ["Common", "Rare", "Super Rare", "Legendary", "Unseen"]:
		for turret in TurretManager.unlockedTurrets:
			if TurretManager.getTurretStat(turret, "rarity") == rarity:
				add_turret_button(turret)

	if _is_vs_match():
		if SteamManager.lobbyID != 0 and SteamManager.check_player_count() > 0:
			if Steam.getLobbyOwner(SteamManager.lobbyID) == SteamManager.steam_id:
				Steam.setLobbyData(SteamManager.lobbyID, "state", "waiting")

		_sync_ready_states_dict()
		SteamManager.lobby_members_updated.connect(_sync_ready_states_dict)
		SteamManager.opponent_loadout_changed.connect(_on_opponent_loadout_changed)

		if DEBUG_OVERLAY:
			_create_debug_overlay()


func _process(delta: float) -> void:
	if not _is_vs_match() or has_triggered_start:
		return

	_poll_accumulator += delta
	if _poll_accumulator >= POLL_INTERVAL:
		_poll_accumulator = 0.0
		_poll_ready_states()

	if DEBUG_OVERLAY:
		_update_debug_overlay()


func _is_vs_match() -> bool:
	return GameManager.VSmode or SteamManager.lobbyID != 0


func _sync_ready_states_dict() -> void:
	if SteamManager.lobbyID == 0:
		return

	var numMembers = Steam.getNumLobbyMembers(SteamManager.lobbyID)
	for i in range(numMembers):
		var mem_id = Steam.getLobbyMemberByIndex(SteamManager.lobbyID, i)
		if not player_ready_states.has(mem_id):
			player_ready_states[mem_id] = false

	_check_all_ready()


func _poll_ready_states() -> void:
	if SteamManager.lobbyID == 0:
		return

	var numMembers = Steam.getNumLobbyMembers(SteamManager.lobbyID)
	for i in range(numMembers):
		var mem_id = Steam.getLobbyMemberByIndex(SteamManager.lobbyID, i)
		var ready_str: String
		if mem_id == SteamManager.steam_id:
			ready_str = "true" if is_local_ready else "false"
		else:
			ready_str = Steam.getLobbyMemberData(SteamManager.lobbyID, mem_id, "is_ready")
		player_ready_states[mem_id] = (ready_str == "true")

	_check_all_ready()


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
		
		if not _is_vs_match():
			launchLabel.show()
			launchButton.show()
			readyLabel.hide()
			readyButton.hide()
		else:
			readyButton.show()
			readyLabel.show()
			launchLabel.hide()
			launchButton.hide()


func _on_remove_button_pressed(btn, turretID):
	btn.queue_free()
	add_turret_button(turretID)
	broughtArray.erase(turretID)
	
	_sync_loadout_to_steam()
	
	if broughtArray.size() <= 0:
		launchLabel.hide()
		launchButton.hide()
		readyLabel.hide()
		readyButton.hide()


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
	if _is_vs_match():
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

	player_ready_states[SteamManager.steam_id] = is_local_ready
	_check_all_ready()


func _on_opponent_loadout_changed(slot: String, value: String) -> void:
	if slot != "is_ready":
		return

	var opponent_id = SteamManager.get_opponent_id()
	if opponent_id != 0:
		player_ready_states[opponent_id] = (value == "true")

	_check_all_ready()


func _check_all_ready() -> void:
	if has_triggered_start or not _is_vs_match():
		return

	var expected_count = SteamManager.check_player_count()
	if expected_count < 2:
		return

	if player_ready_states.size() < expected_count:
		return

	for player_id in player_ready_states:
		if not player_ready_states[player_id]:
			return

	# Everyone in the lobby is readied up - fire the launch locally.
	has_triggered_start = true
	_start_vs_match()


func _start_vs_match() -> void:
	SoundManager.stopMusic()
	GameManager.turretsBrought = broughtArray.duplicate()
	for item in GameManager.turretsBrought:
		GameManager.turretTempLevels[item] = 0
	SoundManager.playStartButtonSound()
	$"../../AnimationPlayer".play("Launch")
	PopupManager.clearCaptainPopups()
	readyButton.disabled = true

	if DEBUG_OVERLAY and _debug_label:
		_debug_label.text += "\n>>> _start_vs_match FIRED <<<"


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
