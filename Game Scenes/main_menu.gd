extends Control

@onready var soloFrame = $"Solo Frame"
@onready var multiplayerFrame = $"Multiplayer Frame"

@onready var readyButton = $"Solo Frame/ReadyButton"
@onready var readyLabel = $ReadyLabel

@onready var createButton = $"Multiplayer Frame/ContainerOne/Create Button"

@onready var lobbyHost = $"Multiplayer Frame/Lobby Host"
@onready var lobbyGuest = $"Multiplayer Frame/Lobby Guest"

@onready var playButtonHolder = $"Play Button Holder"
@onready var genericButtonHolder = $GenericButtonHolder

@onready var portal = $PortalFX
@onready var difficultySlider = $"Solo Frame/Difficulty Slider"
@onready var turretTitle = $TurretTitle
@onready var turretDescriptionOne = $TypeLabel
@onready var difLabel = $DifficultyLabel
@onready var screenFilter = $ScreenFilter
@onready var launchLabel = $LaunchLabel
@onready var launchButton = $"Solo Frame/BeginButton"

@onready var animationPlayer = $AnimationPlayer
@onready var enemyGridContainer = $"Solo Frame/MultiplayerHolder/enemyBringingGrid"

var is_local_ready: bool = false
var is_opponent_ready: bool = false

func _ready() -> void:
	_connect_steam_manager_signals()

	portal.hide()
	SoundManager.stopMusic()
	GameManager.VSmode = false
	Engine.time_scale = 1
	if not SettingsManager.is_tutorial_done():
		get_tree().change_scene_to_file("res://Game Scenes/Tutorial Scene.tscn")
	difficultySlider.value = GameManager.difficultySave
	
	# Connect the launch button via code to ensure it triggers our ready logic
	if not launchButton.pressed.is_connected(_on_begin_button_pressed):
		launchButton.pressed.connect(_on_begin_button_pressed)


func _connect_steam_manager_signals() -> void:
	if not SteamManager.lobby_join_status.is_connected(_on_join_attempt_finished):
		SteamManager.lobby_join_status.connect(_on_join_attempt_finished)
	if not SteamManager.lobby_members_updated.is_connected(_update_player_labels):
		SteamManager.lobby_members_updated.connect(_update_player_labels)
	if not SteamManager.opponent_left_lobby.is_connected(_on_opponent_left):
		SteamManager.opponent_left_lobby.connect(_on_opponent_left)
	if not SteamManager.lobby_disconnected.is_connected(_on_lobby_disconnected):
		SteamManager.lobby_disconnected.connect(_on_lobby_disconnected)
	if not SteamManager.match_state_changed.is_connected(_on_match_state_changed):
		SteamManager.match_state_changed.connect(_on_match_state_changed)
	if not SteamManager.opponent_loadout_changed.is_connected(_on_opponent_loadout_changed):
		SteamManager.opponent_loadout_changed.connect(_on_opponent_loadout_changed)
	if not SteamManager.difficulty_changed.is_connected(_on_steam_difficulty_changed):
		SteamManager.difficulty_changed.connect(_on_steam_difficulty_changed)


func _on_opponent_left() -> void:
	if SteamManager.lobbyHost == SteamManager.steam_name:
		$"Multiplayer Frame/Lobby Host/OpponentNameLabel".text = ""
		$"Multiplayer Frame/Lobby Host/Start Button".hide()
		$"Multiplayer Frame/Lobby Host/Invite Button".show()
	else:
		SteamManager.leaveLobby()
		_on_lobby_disconnected()


func _pulse_name_label(display_name: String, color: String = "purple", freq: float = 0.5) -> String:
	return "[pulse color=%s height=0.5 freq=%s][font_size=32]%s[/font_size][/pulse]" % [color, freq, display_name]


func _on_solo_frame_visibility_changed() -> void:
	if soloFrame != null:
		if soloFrame.visible:
			animationPlayer.play("PortalAppear")
			turretTitle.show()
			turretDescriptionOne.show()
			portal.show()
			difLabel.show()
			
			if launchButton.visible:
				launchLabel.show()
		else:
			difLabel.hide()
			turretTitle.hide()
			turretDescriptionOne.hide()
			portal.hide()
			launchLabel.hide()

# --- Difficulty Syncing Logic ---
func _on_difficulty_slider_value_changed(value: float) -> void:
	_apply_difficulty_visuals(value)
	
	# Broadcast to Steam if in a lobby
	if SteamManager.lobbyID != 0:
		Steam.setLobbyData(SteamManager.lobbyID, "difficulty", str(value))


func _on_steam_difficulty_changed(new_diff: float) -> void:
	# Update local slider silently without re-triggering the send loop
	if difficultySlider.value != new_diff:
		difficultySlider.set_value_no_signal(new_diff)
		_apply_difficulty_visuals(new_diff)


func _apply_difficulty_visuals(value: float) -> void:
	if value >= 1 and value <= 4:
		difLabel.text = "[pulse color=green height=0.5 freq=0.3][font_size=20]Difficulty: " + str(int(value)) + "[/font_size][/pulse]"
	if value >= 5 and value <= 8:
		difLabel.text = "[pulse color=yellow height=0.5 freq=0.3][font_size=20]Difficulty: " + str(int(value)) + "[/font_size][/pulse]"
	if value >= 9:
		difLabel.text = "[pulse color=red height=0.5 freq=0.3][font_size=20]Difficulty: " + str(int(value)) + "[/font_size][/pulse]"
		
	WaveManager.currentDifficulty = int(value)
	portal.material.set_shader_parameter("intensity", value)
	screenFilter.material.set_shader_parameter("speed", 0.1 * value)
	screenFilter.material.set_shader_parameter("orb_count", 25 * value)
	SoundManager.playDifficultySound(int(value))


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Launch":
		get_tree().change_scene_to_file("res://Game Scenes/Game.tscn")
		GameManager.difficultySave = WaveManager.currentDifficulty


# --- Multiplayer UI ---

func _on_create_button_pressed() -> void:
	createButton.hide()
	lobbyHost.show()
	SteamManager.create_vs_lobby()


func _on_invite_button_pressed() -> void:
	SteamManager.invite_user()


func _on_join_attempt_finished(success: bool) -> void:
	if success and SteamManager.lobbyHost != SteamManager.steam_name:
		$"Back Button".show()
		soloFrame.hide()
		multiplayerFrame.show()
		lobbyHost.hide()
		lobbyGuest.show()
		playButtonHolder.hide()
		genericButtonHolder.hide()
		$"Multiplayer Frame/ContainerOne".hide()
	else:
		print("Failed to join")


func _update_player_labels() -> void:
	if SteamManager.lobbyHost == SteamManager.steam_name:
		$"Multiplayer Frame/Lobby Host/OpponentNameLabel".text = _pulse_name_label(SteamManager.opponentName)
	else:
		$"Multiplayer Frame/Lobby Guest/OpponentNameLabel".text = _pulse_name_label(SteamManager.opponentName)

	if SteamManager.check_player_count() >= 2:
		$"Multiplayer Frame/Lobby Host/Invite Button".hide()
		$"Multiplayer Frame/Lobby Host/Start Button".show()


func resetMultiplayerData() -> void:
	$"Multiplayer Frame/Lobby Host".hide()
	$"Multiplayer Frame/Lobby Guest".hide()
	$"Multiplayer Frame/Lobby Guest/OpponentNameLabel".text = ""
	$"Solo Frame/MultiplayerHolder".hide()
	$"Solo Frame/MultiplayerHolder/OpponentName".text = _pulse_name_label("", "#9ffff5", 0.3)
	soloFrame.hide()
	multiplayerFrame.hide()
	$"Play Button Holder".hide()
	$GenericButtonHolder.show()
	GameManager.VSmode = false
	
	# Reset ready states
	is_local_ready = false
	is_opponent_ready = false
	if launchButton:
		launchButton.disabled = false
	if launchLabel:
		launchLabel.text = "[steel]Launch[/steel]"


func _on_lobby_disconnected() -> void:
	$"Multiplayer Frame/ContainerOne".show()
	createButton.show()


func _on_start_button_pressed() -> void:
	GameManager.VSmode = true
	SteamManager.advance_to_loadout()


func _on_match_state_changed(new_state: String) -> void:
	if new_state == "loadout":
		
		# --- 1. SET UP BUTTON VISIBILITY FIRST ---
		if GameManager.VSmode:
			if SteamManager.lobbyHost == SteamManager.steam_name:
				# HOST: Show Launch, Hide Ready
				launchButton.show()
				if readyButton: readyButton.hide()
				if readyLabel: readyLabel.hide()
			else:
				# GUEST: Hide Launch, Show Ready
				launchButton.hide()
				launchLabel.hide()
				if readyButton: readyButton.show()
				if readyLabel: readyLabel.show()
				
		# --- 2. NOW SHOW THE FRAME ---
		multiplayerFrame.hide()
		soloFrame.show()
		$"Solo Frame/MultiplayerHolder".show()
		$"Solo Frame/MultiplayerHolder/OpponentName".text = _pulse_name_label(SteamManager.opponentName, "#9ffff5", 0.3)
				
	elif new_state == "start_game":
		animationPlayer.play("Launch")


func _on_opponent_loadout_changed(slot: String, data: String) -> void:
	if slot == "is_ready":
		if data == "true":
			is_opponent_ready = true
			if SteamManager.lobbyHost == SteamManager.steam_name:
				launchLabel.text = "LAUNCH"
				launchButton.disabled = false
		else:
			is_opponent_ready = false
			if SteamManager.lobbyHost == SteamManager.steam_name:
				launchLabel.text = "WAITING FOR GUEST..."
				launchButton.disabled = true
		return
		
	if slot != "loadout_list":
		return

	for child in enemyGridContainer.get_children():
		child.queue_free()

	if data == "":
		return

	for turret_str in data.split(","):
		if turret_str == "":
			continue

		var turret_id = TurretManager.getTurretIdFromString(turret_str)
		if turret_id == -1:
			continue

		var texture = TurretManager.getTurretTexture(turret_id)
		if texture == null:
			continue

		var icon = Button.new()
		icon.icon = texture
		icon.flat = true
		icon.disabled = true
		icon.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.expand_icon = true
		icon.custom_minimum_size = Vector2(24, 24)
		icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
		enemyGridContainer.add_child(icon)


# --- Ready Up Logic ---

func _on_begin_button_pressed() -> void:
	if GameManager.VSmode:
		is_local_ready = true
		launchButton.disabled = true
		launchLabel.text = "READY..."
		SteamManager.set_loadout_slot("is_ready", "true")
		_check_both_ready()
	else:
		# If playing solo, just start normally
		animationPlayer.play("Launch")


func _check_both_ready() -> void:
	if is_local_ready and is_opponent_ready:
		if SteamManager.lobbyHost == SteamManager.steam_name:
			Steam.setLobbyData(SteamManager.lobbyID, "match_state", "start_game")
