extends Control

@onready var create_btn   = $CreateButton
@onready var join_btn     = $JoinButton
@onready var code_input   = $CodeInput
@onready var status_label = $StatusLabel
@onready var code_display = $CodeLabel
@onready var lobby_panel  = $LobbyPanel
@onready var player_list  = $LobbyPanel/PlayerList
@onready var room_label   = $LobbyPanel/RoomLabel
@onready var start_btn    = $LobbyPanel/StartButton
@onready var invite_btn   = $LobbyPanel/InviteButton

var _has_loaded: bool = false

func _ready() -> void:
	code_display.hide()
	lobby_panel.hide()

	# 1. Connect to your custom SteamManager signals
	SteamManager.lobby_created.connect(_on_lobby_ready)
	SteamManager.lobby_joined.connect(_on_lobby_ready)
	SteamManager.lobby_join_failed.connect(_on_join_failed)
	SteamManager.lobby_members_updated.connect(_refresh_players)
	SteamManager.friend_invite_accepted.connect(_on_friend_invite)

	# 2. Connect directly to GodotSteam's built-in data update signal
	# This completely replaces the need for _process polling
	Steam.lobby_data_update.connect(_on_lobby_data_update)

	# 3. Handle lobbies joined prior to scene loading
	if SteamManager.current_lobby_id != 0:
		_on_lobby_ready(SteamManager.current_lobby_id)
	elif SteamManager.pending_lobby_id != 0:
		print("Catching pending lobby: ", SteamManager.pending_lobby_id)
		_on_lobby_ready(SteamManager.pending_lobby_id)


# ─────────────────────────────────────────
#  CREATE / JOIN
# ─────────────────────────────────────────

func _on_create_button_pressed() -> void:
	if not SteamManager.steam_initialized:
		status_label.text = "Steam not running!"
		return
	status_label.text = "Creating lobby..."
	SteamManager.create_lobby()

func _on_join_button_pressed() -> void:
	if not SteamManager.steam_initialized:
		status_label.text = "Steam not running!"
		return
	var code = code_input.text.strip_edges()
	if code.is_empty():
		status_label.text = "Enter a lobby code"
		return
	status_label.text = "Joining..."
	SteamManager.join_lobby_by_code(code)

func _on_join_failed() -> void:
	status_label.text = "Failed to join. Check the code."


# ─────────────────────────────────────────
#  INVITE ACCEPTED
# ─────────────────────────────────────────

func _on_friend_invite(_lobby_id: int) -> void:
	if get_tree().current_scene != self:
		get_tree().change_scene_to_file("res://Game Scenes/MainMenu.tscn")
	else:
		status_label.text = "Joining via invite..."
		lobby_panel.show()


# ─────────────────────────────────────────
#  LOBBY UI
# ─────────────────────────────────────────

func _on_lobby_ready(_lobby_id: int) -> void:
	SteamManager.pending_lobby_id = 0  # Clear pending ID
	
	# Hide main menu elements
	create_btn.hide()
	join_btn.hide()
	code_input.hide()
	status_label.hide()
	
	# Show lobby elements
	lobby_panel.show()

	# Host vs Client UI Setup
	if SteamManager.is_host():
		room_label.text = "Code: %d" % SteamManager.current_lobby_id
		code_display.text = "Room Code: %d" % SteamManager.current_lobby_id
		code_display.show()
		start_btn.show()
		invite_btn.show()
		
		# Initialize the lobby state for late joiners
		Steam.setLobbyData(SteamManager.current_lobby_id, "state", "waiting")
	else:
		room_label.text = "Lobby"
		code_display.hide()
		start_btn.hide()
		invite_btn.hide()

	_refresh_players()

func _refresh_players(_dummy = null) -> void:
	player_list.clear()

	if SteamManager.current_lobby_id == 0:
		return

	for member in SteamManager.get_lobby_members():
		var is_me = member["steam_id"] == SteamManager.steam_id
		var is_owner = member["steam_id"] == Steam.getLobbyOwner(SteamManager.current_lobby_id)
		
		var tag = ""
		if is_owner: tag += "👑 "
		if is_me: tag += " (You)"
		
		player_list.add_item("%s%s" % [tag, member["name"]])

func _on_invite_button_pressed() -> void:
	if not SteamManager.steam_initialized:
		return
	SteamManager.open_invite_overlay()


# ─────────────────────────────────────────
#  START GAME & SCENE TRANSITION
# ─────────────────────────────────────────

func _on_start_button_pressed() -> void:
	if not SteamManager.is_host():
		return
		
	# Changing the lobby data here automatically broadcasts to all clients
	Steam.setLobbyData(SteamManager.current_lobby_id, "state", "loading")

func _on_lobby_data_update(lobby_id: int, _member_id: int, _success: bool) -> void:
	# Ignore updates from old lobbies or if we already loaded
	if lobby_id != SteamManager.current_lobby_id or SteamManager.current_lobby_id == 0:
		return
	if _has_loaded:
		return

	# Check the updated state
	var state = Steam.getLobbyData(lobby_id, "state")
	if state == "loading":
		_has_loaded = true
		GameManager.VSmode = true
		get_tree().change_scene_to_file("res://Game Scenes/Loadout.tscn")


# ─────────────────────────────────────────
#  LEAVE
# ─────────────────────────────────────────

func _on_leave_button_pressed() -> void:
	SteamManager.leave_lobby()
	
	# Reset Lobby UI
	lobby_panel.hide()
	code_display.hide()
	code_display.text = ""
	status_label.text = ""
	_has_loaded = false
	
	# Show Main Menu UI
	create_btn.show()
	join_btn.show()
	code_input.show()
	status_label.show()
