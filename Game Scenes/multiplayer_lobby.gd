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

var has_loaded_game: bool = false  # prevents double scene change


func _ready():
	code_display.hide()
	lobby_panel.hide()

	SteamManager.lobby_created.connect(_on_lobby_ready)
	SteamManager.lobby_joined.connect(_on_lobby_ready)
	SteamManager.lobby_join_failed.connect(_on_join_failed)
	SteamManager.lobby_members_updated.connect(_refresh_players)
	SteamManager.friend_invite_accepted.connect(_on_friend_invite)


# ─────────────────────────────────────────
#  CREATE / JOIN
# ─────────────────────────────────────────

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


# ─────────────────────────────────────────
#  INVITE ACCEPTED
# ─────────────────────────────────────────

func _on_friend_invite(_lobby_id: int):
	# If the friend accepted an invite while on this screen,
	# _on_lobby_ready will fire via lobby_joined — nothing extra needed.
	# If they're on a different scene entirely, bring them here first.
	if get_tree().current_scene != self:
		get_tree().change_scene_to_file("res://Game Scenes/MainMenu.tscn")
	else:
		# Already on this scene — lobby_joined will handle the rest
		status_label.text = "Joining via invite..."


# ─────────────────────────────────────────
#  LOBBY UI
# ─────────────────────────────────────────

func _on_lobby_ready(_lobby_id: int):
	lobby_panel.show()
	has_loaded_game = false  # reset in case they left and rejoined

	if SteamManager.is_host():
		room_label.text = "Code: %d" % SteamManager.current_lobby_id
		code_display.text = "Room Code: %d" % SteamManager.current_lobby_id
		code_display.show()
		status_label.text = "Waiting for players..."
		start_btn.show()
		invite_btn.show()
	else:
		room_label.text = "Joined lobby"
		code_display.hide()
		status_label.text = "Waiting for host to start..."
		start_btn.hide()
		invite_btn.show()

	_refresh_players()


func _refresh_players(_dummy = null):
	player_list.clear()

	if SteamManager.current_lobby_id == 0:
		return

	for member in SteamManager.get_lobby_members():
		var is_me = member["steam_id"] == SteamManager.steam_id
		var is_owner = member["steam_id"] == Steam.getLobbyOwner(SteamManager.current_lobby_id)

		var row = HBoxContainer.new()

		# Crown for host
		if is_owner:
			var crown = Label.new()
			crown.text = "👑 "
			row.add_child(crown)

		# Player name
		var name_label = Label.new()
		name_label.text = member["name"]
		if is_me:
			name_label.text += " (You)"
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)

		player_list.add_child(row)


# ─────────────────────────────────────────
#  INVITE BUTTON
# ─────────────────────────────────────────

func _on_invite_button_pressed():
	if not SteamManager.steam_initialized:
		return
	SteamManager.open_invite_overlay()


# ─────────────────────────────────────────
#  START GAME
# ─────────────────────────────────────────

func _on_start_button_pressed():
	if not SteamManager.is_host():
		return
	Steam.setLobbyData(SteamManager.current_lobby_id, "state", "loading")


func _process(_delta):
	if SteamManager.current_lobby_id == 0:
		return
	if has_loaded_game:
		return
	var state = Steam.getLobbyData(SteamManager.current_lobby_id, "state")
	if state == "loading":
		has_loaded_game = true  # prevent double trigger
		GameManager.VSmode = true
		get_tree().change_scene_to_file("res://Game Scenes/Loadout.tscn")


# ─────────────────────────────────────────
#  LEAVE
# ─────────────────────────────────────────

func _on_leave_button_pressed() -> void:
	SteamManager.leave_lobby()
	lobby_panel.hide()
	code_display.hide()
	code_display.text = ""
	status_label.text = ""
	has_loaded_game = false
