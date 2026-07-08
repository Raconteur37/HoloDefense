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

	SteamManager.lobby_created.connect(_on_lobby_ready)
	SteamManager.lobby_joined.connect(_on_lobby_ready)
	SteamManager.lobby_join_failed.connect(_on_join_failed)
	SteamManager.friend_invite_accepted.connect(_on_friend_invite)

	# Wire directly to Steam's internal networking alerts
	Steam.lobby_data_update.connect(_on_lobby_data_update)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)

	if SteamManager.current_lobby_id != 0:
		_on_lobby_ready(SteamManager.current_lobby_id)
	elif SteamManager.pending_lobby_id != 0:
		_on_lobby_ready(SteamManager.pending_lobby_id)

# ─────────────────────────────────────────
#  HELPER: OWNER VERIFICATION
# ─────────────────────────────────────────
func is_user_host() -> bool:
	if SteamManager.current_lobby_id == 0:
		return false
	return Steam.getLobbyOwner(SteamManager.current_lobby_id) == Steam.getSteamID()

# ─────────────────────────────────────────
#  BUTTON INTERACTIONS
# ─────────────────────────────────────────
func _on_create_button_pressed() -> void:
	status_label.text = "Creating lobby..."
	SteamManager.create_lobby()

func _on_join_button_pressed() -> void:
	var code = code_input.text.strip_edges()
	if code.is_empty():
		status_label.text = "Enter a lobby code"
		return
	status_label.text = "Joining..."
	SteamManager.join_lobby_by_code(code)

func _on_join_failed() -> void:
	status_label.text = "Failed to join. Check the code."

func _on_friend_invite(_lobby_id: int) -> void:
	if get_tree().current_scene != self:
		get_tree().change_scene_to_file("res://Game Scenes/MainMenu.tscn")
	else:
		status_label.text = "Joining via invite..."
		lobby_panel.show()

# ─────────────────────────────────────────
#  LOBBY MANAGEMENT
# ─────────────────────────────────────────
func _on_lobby_ready(_lobby_id: int) -> void:
	SteamManager.pending_lobby_id = 0  
	
	create_btn.hide()
	join_btn.hide()
	code_input.hide()
	status_label.hide()
	lobby_panel.show()

	if is_user_host():
		room_label.text = "Code: %d" % SteamManager.current_lobby_id
		code_display.text = "Room Code: %d" % SteamManager.current_lobby_id
		code_display.show()
		start_btn.show()
		invite_btn.show()
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

	var num_members = Steam.getNumLobbyMembers(SteamManager.current_lobby_id)
	for i in range(num_members):
		var member_steam_id = Steam.getLobbyMemberByIndex(SteamManager.current_lobby_id, i)
		var member_name = Steam.getFriendPersonaName(member_steam_id)
		
		var is_me = (member_steam_id == Steam.getSteamID())
		var is_owner = (member_steam_id == Steam.getLobbyOwner(SteamManager.current_lobby_id))
		
		var tag = ""
		if is_owner: tag += "👑 "
		if is_me: tag += " (You)"
		
		player_list.add_item("%s%s" % [tag, member_name])

func _on_invite_button_pressed() -> void:
	SteamManager.open_invite_overlay()

# ─────────────────────────────────────────
#  SIGNAL-SAFE NETWORK TRANSITIONS
# ─────────────────────────────────────────
func _on_start_button_pressed() -> void:
	print("Start button pressed!")
	if not is_user_host():
		print("ERROR: Start failed. Steam says you are NOT the host.")
		return
		
	print("Host verified. Changing lobby data to 'loading'...")
	Steam.setLobbyData(SteamManager.current_lobby_id, "state", "loading")

# REMOVED STATIC TYPING FROM PARAMETERS TO PREVENT GODOT 4 SIGNAL DROPPING
func _on_lobby_data_update(lobby_id, member_id, success) -> void:
	print("Steam Data Update! Lobby: ", lobby_id, " | Success: ", success)
	
	# Update player profile rendering (resolves invisible teammate bug)
	_refresh_players()
	
	if lobby_id != SteamManager.current_lobby_id or SteamManager.current_lobby_id == 0:
		return
	if _has_loaded:
		return

	var state = Steam.getLobbyData(lobby_id, "state")
	if state == "loading":
		print("Steam verification received! Transfereing to Loadout...")
		_has_loaded = true
		GameManager.VSmode = true
		get_tree().change_scene_to_file("res://Game Scenes/Loadout.tscn")

# REMOVED STATIC TYPING HERE AS WELL
func _on_lobby_chat_update(lobby_id, changed_id, making_change_id, chat_state) -> void:
	print("Steam Chat Update! Processing layout refresh...")
	_refresh_players()

# ─────────────────────────────────────────
#  LEAVE CONTROL UI
# ─────────────────────────────────────────
func _on_leave_button_pressed() -> void:
	SteamManager.leave_lobby()
	
	lobby_panel.hide()
	code_display.hide()
	code_display.text = ""
	status_label.text = ""
	_has_loaded = false
	
	create_btn.show()
	join_btn.show()
	code_input.show()
	status_label.show()
