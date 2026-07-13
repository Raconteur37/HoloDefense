extends Control

@onready var scroll = $TurretSelectionScroll/ScrollContainer
@onready var hbox = $TurretSelectionScroll/ScrollContainer/HBoxContainer
@onready var bringingGrid = $BringingGrid
@onready var difSlider = $VSlider
@onready var difLabel = $DifficultyLabel
@onready var beginButton = $BeginButton
@onready var ready_button = $ReadyButton
@onready var player_list = $PlayerReadyList
@onready var waiting_label = $WaitingLabel
@onready var readyLabel = $ReadyButton/RichTextLabel

@onready var animationPlayer = $AnimationPlayer

var broughtArray: Array = []
var player_ready_states: Dictionary = {}
var is_multiplayer: bool = false
var is_ready: bool = false
var has_started: bool = false
var has_triggered_start: bool = false


func _ready() -> void:
	SoundManager.playLoadoutMusic()
	difSlider.value = GameManager.difficultySave
	
	scroll.custom_minimum_size = Vector2(700, 150)

	for rarity in ["Common", "Rare", "Super Rare", "Legendary", "Unseen"]:
		for turret in TurretManager.unlockedTurrets:
			if TurretManager.getTurretStat(turret, "rarity") == rarity:
				add_turret_button(turret)

	is_multiplayer = GameManager.VSmode

	if is_multiplayer:
		# ← Reset lobby state so _process doesn't instantly trigger
		if SteamManager.is_host():
			Steam.setLobbyData(SteamManager.current_lobby_id, "state", "waiting")

	if is_multiplayer:
		for member in SteamManager.get_lobby_members():
			player_ready_states[member["steam_id"]] = false

		SteamManager.lobby_members_updated.connect(_refresh_player_list)

		player_list.show()
		waiting_label.hide()
		ready_button.hide()
		beginButton.hide()
		_refresh_player_list()
	else:
		player_list.hide()
		waiting_label.hide()
		ready_button.hide()
		beginButton.hide()


# ─────────────────────────────────────────
#  PROCESS — POLL LOBBY STATE
# ─────────────────────────────────────────

func _process(_delta: float) -> void:
	if not is_multiplayer:
		return
	if SteamManager.current_lobby_id == 0:
		return

	if not has_started:
		var state = Steam.getLobbyData(SteamManager.current_lobby_id, "state")
		# ← Only trigger on "loading", ignore "waiting" and anything else
		if state == "loading":
			has_started = true
			print("State is loading — changing scene...")
			get_tree().change_scene_to_file("res://Game Scenes/Game.tscn")
			return

	if SteamManager.is_host() and not has_triggered_start:
		_poll_member_ready_states()


func _poll_member_ready_states() -> void:
	var members = SteamManager.get_lobby_members()
	var changed = false

	for member in members:
		var sid = member["steam_id"]
		var ready_str = Steam.getLobbyMemberData(SteamManager.current_lobby_id, sid, "ready")
		var ready = (ready_str == "true")
		if player_ready_states.get(sid, false) != ready:
			player_ready_states[sid] = ready
			changed = true

	if changed:
		_refresh_player_list()
		_check_all_ready()


func add_turret_button(turretID):
	if EconomyManager.is_turret_unlocked(turretID):
		var btn = Button.new()
		btn.icon = TurretManager.getTurretTexture(turretID)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_turret_button_pressed.bind(btn, turretID))
		hbox.add_child(btn)


func add_remove_button(turretID):
	var btn = Button.new()
	btn.icon = TurretManager.getTurretTexture(turretID)
	btn.custom_minimum_size = Vector2(150, 150)
	btn.expand_icon = true
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(_on_remove_button_pressed.bind(btn, turretID))
	bringingGrid.add_child(btn)


func _on_turret_button_pressed(btn, turretID):
	if broughtArray.size() < 10:
		btn.queue_free()
		broughtArray.append(turretID)
		add_remove_button(turretID)
	if broughtArray.size() >= 1:
		_on_loadout_full()


func _on_remove_button_pressed(btn, turretID):
	btn.queue_free()
	add_turret_button(turretID)
	broughtArray.erase(turretID)
	_on_loadout_incomplete()


func _on_v_slider_value_changed(value: float) -> void:
	if value >= 1 and value <= 4:
		difLabel.text = "[pulse color=green height=0.5 freq=0.3][font_size=30]Difficulty: " + str(int(value)) + "[/font_size][/pulse]"
	if value >= 5 and value <= 8:
		difLabel.text = "[pulse color=yellow height=0.5 freq=0.3][font_size=30]Difficulty: " + str(int(value)) + "[/font_size][/pulse]"
	if value >= 9:
		difLabel.text = "[pulse color=red height=0.5 freq=0.3][font_size=30]Difficulty: " + str(int(value)) + "[/font_size][/pulse]"
	WaveManager.currentDifficulty = int(value)
	#print(WaveManager.currentDifficulty)
	SoundManager.playDifficultySound(int(value))


func _on_turret_info_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Turret Info.tscn")


func _on_loadout_full():
	if is_multiplayer:
		ready_button.show()
		beginButton.hide()
	else:
		beginButton.show()
		ready_button.hide()


func _on_loadout_incomplete():
	ready_button.hide()
	beginButton.hide()
	if is_multiplayer and is_ready:
		is_ready = false
		readyLabel.parse_bbcode("[rainbow freq=.1 sat=1 val=0.8][font_size=90]Ready?[/font_size][/rainbow]")
		waiting_label.hide()
		_set_my_ready_state(false)


func _on_begin_button_pressed() -> void:
	if is_multiplayer:
		return
	SoundManager.stopLoadoutMusic()
	GameManager.turretsBrought = broughtArray.duplicate()
	for item in GameManager.turretsBrought:
		GameManager.turretTempLevels[item] = 0
	SoundManager.playStartButtonSound()
	animationPlayer.play("BeginRun")


# ─────────────────────────────────────────
#  MULTIPLAYER READY
# ─────────────────────────────────────────

func _on_ready_button_pressed() -> void:
	if not is_multiplayer:
		return

	is_ready = !is_ready

	if is_ready:
		GameManager.turretsBrought = broughtArray.duplicate()
		for item in GameManager.turretsBrought:
			GameManager.turretTempLevels[item] = 0
		readyLabel.parse_bbcode("[rainbow freq=.1 sat=1 val=0.8][font_size=90]Unready[/font_size][/rainbow]")
		waiting_label.show()
	else:
		readyLabel.parse_bbcode("[rainbow freq=.1 sat=1 val=0.8][font_size=90]Ready?[/font_size][/rainbow]")
		waiting_label.hide()

	_set_my_ready_state(is_ready)


func _set_my_ready_state(state: bool) -> void:
	Steam.setLobbyMemberData(SteamManager.current_lobby_id, "ready", "true" if state else "false")
	
	# Update local dict immediately
	player_ready_states[SteamManager.steam_id] = state
	_refresh_player_list()

	# Host checks immediately using local dict — don't wait for poll
	if SteamManager.is_host():
		_check_all_ready()


func _check_all_ready() -> void:
	if has_triggered_start:
		return

	var members = SteamManager.get_lobby_members()
	if members.is_empty():
		return

	# Require at least 1 player (change to 2 for release)
	const MIN_PLAYERS = 1

	if members.size() < MIN_PLAYERS:
		return

	for member in members:
		var sid = member["steam_id"]
		# Check local dict first — more reliable than Steam propagation delay
		if not player_ready_states.get(sid, false):
			return

	has_triggered_start = true
	print("All players ready — starting game!")
	Steam.setLobbyData(SteamManager.current_lobby_id, "state", "loading")

# ─────────────────────────────────────────
#  PLAYER READY LIST UI
# ─────────────────────────────────────────

func _refresh_player_list(_dummy = null):
	if not is_instance_valid(player_list):
		return

	for child in player_list.get_children():
		child.queue_free()

	for member in SteamManager.get_lobby_members():
		var sid = member["steam_id"]
		var ready = player_ready_states.get(sid, false)
		var is_me = sid == SteamManager.steam_id
		var is_owner = sid == Steam.getLobbyOwner(SteamManager.current_lobby_id)

		var row = HBoxContainer.new()

		var dot = Label.new()
		dot.text = "●"
		dot.modulate = Color.GREEN if ready else Color.RED
		dot.custom_minimum_size = Vector2(20, 0)
		row.add_child(dot)

		if is_owner:
			var crown = Label.new()
			crown.text = "👑 "
			row.add_child(crown)

		var name_label = Label.new()
		name_label.text = member["name"]
		if is_me:
			name_label.text += " (You)"
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)

		var status_label = Label.new()
		status_label.text = "Ready!" if ready else "Picking..."
		status_label.modulate = Color.GREEN if ready else Color.YELLOW
		row.add_child(status_label)

		player_list.add_child(row)


func _on_turret_info_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Main Menu.tscn")
	SoundManager.stopMusic()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "BeginRun":
		get_tree().change_scene_to_file("res://Game Scenes/Game.tscn")
		GameManager.difficultySave = WaveManager.currentDifficulty
