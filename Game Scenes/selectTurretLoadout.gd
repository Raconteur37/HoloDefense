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

var broughtArray: Array = []
var player_ready_states: Dictionary = {}

# Convenience — true only when actually in a multiplayer session
var is_multiplayer: bool = false


func _ready() -> void:
	scroll.custom_minimum_size = Vector2(700, 150)

	for rarity in ["Common", "Rare", "Super Rare", "Legendary", "Unseen"]:
		for turret in TurretManager.unlockedTurrets:
			if TurretManager.getTurretStat(turret, "rarity") == rarity:
				add_turret_button(turret)

	# Determine mode from GameManager
	is_multiplayer = GameManager.VSmode

	if is_multiplayer:
		# Init ready states for all connected players
		for id in NetworkManager.players:
			player_ready_states[id] = false
		_refresh_player_list()
		player_list.show()
		waiting_label.hide()
		ready_button.hide()
		beginButton.hide()
	else:
		# Singleplayer — hide all multiplayer UI
		player_list.hide()
		waiting_label.hide()
		ready_button.hide()
		beginButton.hide()


func add_turret_button(turretID):
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
	if broughtArray.size() >= 10:
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

	# If they were ready, unready them when they change their loadout
	if is_multiplayer and is_ready:
		is_ready = false
		ready_button.text = "Ready!"
		ready_button.modulate = Color.WHITE
		waiting_label.hide()
		_submit_ready.rpc_id(1, multiplayer.get_unique_id(), false, [])


func _on_begin_button_pressed() -> void:
	if is_multiplayer:
		return  # safety — shouldn't be reachable in VS mode
	GameManager.turretsBrought = broughtArray.duplicate()
	for item in GameManager.turretsBrought:
		GameManager.turretTempLevels[item] = 0
	get_tree().change_scene_to_file("res://Game Scenes/Game.tscn")


var is_ready: bool = false

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

	player_ready_states[multiplayer.get_unique_id()] = is_ready
	_refresh_player_list()
	
	if multiplayer.is_server():
		_submit_ready(multiplayer.get_unique_id(), is_ready, broughtArray)
	else:
		_submit_ready.rpc_id(1, multiplayer.get_unique_id(), is_ready, broughtArray)

@rpc("any_peer", "reliable")
func _submit_ready(peer_id: int, ready_state: bool, loadout: Array):
	if not multiplayer.is_server():
		return

	var actual_sender = multiplayer.get_remote_sender_id()
	if actual_sender != peer_id and actual_sender != 0:
		return

	player_ready_states[peer_id] = ready_state

	if ready_state:
		NetworkManager.players[peer_id]["loadout"] = loadout

	# ← call_local ensures the server's own list refreshes too
	_sync_ready_states.rpc(player_ready_states)

	for id in NetworkManager.players:
		if not player_ready_states.get(id, false):
			return

	_begin_game.rpc()


@rpc("authority", "call_local", "reliable")
func _sync_ready_states(states: Dictionary):
	player_ready_states = states
	_refresh_player_list()


@rpc("authority", "call_local", "reliable")
func _begin_game():
	get_tree().change_scene_to_file("res://Game Scenes/Game.tscn")

# ─────────────────────────────────────────
#  PLAYER READY LIST UI
# ─────────────────────────────────────────

func _refresh_player_list():
	if not is_instance_valid(player_list):
		return

	for child in player_list.get_children():
		child.queue_free()

	for id in NetworkManager.players:
		var pdata = NetworkManager.players[id]
		var ready = player_ready_states.get(id, false)

		var row = HBoxContainer.new()

		# Ready indicator dot
		var dot = Label.new()
		dot.text = "●"
		dot.modulate = Color.GREEN if ready else Color.RED
		dot.custom_minimum_size = Vector2(20, 0)
		row.add_child(dot)

		# Player name
		var name_label = Label.new()
		name_label.text = pdata.get("name", "Player %d" % id)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)

		# Ready status text
		var status_label = Label.new()
		status_label.text = "Ready!" if ready else "Picking..."
		status_label.modulate = Color.GREEN if ready else Color.YELLOW
		row.add_child(status_label)

		player_list.add_child(row)
