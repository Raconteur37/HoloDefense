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
@onready var invite_btn   = $LobbyPanel/InviteButton  # ADD this Button to your scene


func _ready():
	code_display.hide()
	lobby_panel.hide()

	SteamManager.lobby_created.connect(_on_lobby_ready)
	SteamManager.lobby_joined.connect(_on_lobby_ready)
	SteamManager.lobby_join_failed.connect(_on_join_failed)
	SteamManager.lobby_members_updated.connect(_refresh_players)

	# If friend accepted invite before this scene loaded
	SteamManager.friend_invite_accepted.connect(_on_friend_invite)


func _on_create_button_pressed():
	if not SteamManager.steam_initialized:
		status_label.text = "Steam not running!"
		return
	status_label.text = "Creating lobby..."
	SteamManager.create_lobby()


func _on_join_button_pressed():
	if not SteamManager.steam_initialized:
		status_label.text = "Steam not running!"
		return
	var code = code_input.text.strip_edges()
	if code.is_empty():
		status_label.text = "Enter a lobby code"
		return
	status_label.text = "Joining..."
	SteamManager.join_lobby_by_code(code)


func _on_join_failed():
	status_label.text = "Failed to join. Check the code."


func _on_friend_invite(_lobby_id: int):
	# Game was opened via Steam invite — go straight to lobby screen
	if get_tree().current_scene != self:
		get_tree().change_scene_to_file("res://Game Scenes/MainMenu.tscn")


# ─────────────────────────────────────────
#  LOBBY UI
# ─────────────────────────────────────────

func _on_lobby_ready(_lobby_id: int):
	lobby_panel.show()

	if SteamManager.is_host():
		room_label.text = "Code: %d" % SteamManager.current_lobby_id
		code_display.text = "Room Code: %d" % SteamManager.current_lobby_id
		code_display.show()
		start_btn.show()
		invite_btn.show()
	else:
		room_label.text = "Joined lobby"
		start_btn.hide()
		invite_btn.show()  # clients can also invite friends

	_refresh_players()


func _refresh_players():
	player_list.clear()
	for member in SteamManager.get_lobby_members():
		var is_me = member["steam_id"] == SteamManager.steam_id
		var is_host = member["steam_id"] == Steam.getLobbyOwner(SteamManager.current_lobby_id)
		var tag = ""
		if is_me: tag += " (You)"
		if is_host: tag += " 👑"
		player_list.add_item("%s%s" % [member["name"], tag])


func _on_invite_button_pressed():
	SteamManager.open_invite_overlay()


# ─────────────────────────────────────────
#  START GAME
# ─────────────────────────────────────────

func _on_start_button_pressed():
	if not SteamManager.is_host():
		return
	# Signal all lobby members to load the game
	Steam.setLobbyData(SteamManager.current_lobby_id, "state", "loading")


func _process(_delta):
	if SteamManager.current_lobby_id == 0:
		return
	var state = Steam.getLobbyData(SteamManager.current_lobby_id, "state")
	if state == "loading":
		# Reset so it doesn't trigger twice
		SteamManager.current_lobby_id = 0
		GameManager.VSmode = true
		get_tree().change_scene_to_file("res://Game Scenes/Loadout.tscn")
