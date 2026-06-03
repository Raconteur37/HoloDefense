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
var _has_loaded: bool = false

func _ready():
	code_display.hide()
	lobby_panel.hide()

	SteamManager.lobby_created.connect(_on_lobby_ready)
	SteamManager.lobby_joined.connect(_on_lobby_ready)
	SteamManager.lobby_join_failed.connect(_on_join_failed)
	SteamManager.lobby_members_updated.connect(_refresh_players)
	SteamManager.friend_invite_accepted.connect(_on_friend_invite)

	if SteamManager.current_lobby_id != 0:
		_on_lobby_ready(SteamManager.current_lobby_id)
	elif SteamManager.pending_lobby_id != 0:
		# Lobby was joined before this scene loaded — join it now
		print("Catching pending lobby: ", SteamManager.pending_lobby_id)
		_on_lobby_ready(SteamManager.pending_lobby_id)



# ─────────────────────────────────────────
#  CREATE / JOIN
# ─────────────────────────────────────────

func _wait_for_invite_join() -> void:
	# Check every 0.5s for up to 5 seconds
	for i in range(10):
		await get_tree().create_timer(0.5).timeout
		if SteamManager.current_lobby_id != 0:
			print("Caught lobby join after delay: ", SteamManager.current_lobby_id)
			_on_lobby_ready(SteamManager.current_lobby_id)
			return

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
	SteamManager.pending_lobby_id = 0  # ← clear it so it doesn't retrigger

	create_btn.hide()
	join_btn.hide()
	code_input.hide()
	status_label.hide()
	lobby_panel.show()

	if SteamManager.is_host():
		room_label.text = "Code: %d" % SteamManager.current_lobby_id
		code_display.text = "Room Code: %d" % SteamManager.current_lobby_id
		code_display.show()
		start_btn.show()
		invite_btn.show()
	else:
		room_label.text = "Lobby"
		code_display.hide()
		start_btn.hide()
		invite_btn.hide()

	_refresh_players()


func _refresh_players(_dummy = null):
	player_list.clear()  # works for ItemList

	if SteamManager.current_lobby_id == 0:
		return

	for member in SteamManager.get_lobby_members():
		var is_me = member["steam_id"] == SteamManager.steam_id
		var is_owner = member["steam_id"] == Steam.getLobbyOwner(SteamManager.current_lobby_id)
		var tag = ""
		if is_owner: tag += "👑 "
		if is_me: tag += " (You)"
		player_list.add_item("%s%s" % [tag, member["name"]])  # ItemList.add_item


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
	# Reset state first then set to loading so clients detect the change
	Steam.setLobbyData(SteamManager.current_lobby_id, "state", "waiting")
	await get_tree().process_frame
	Steam.setLobbyData(SteamManager.current_lobby_id, "state", "loading")


func _process(_delta):
	if SteamManager.current_lobby_id == 0:
		return
	if _has_loaded:
		return
	if not lobby_panel.visible:
		return

	var state = Steam.getLobbyData(SteamManager.current_lobby_id, "state")
	if state == "loading":
		_has_loaded = true
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
	_has_loaded = false  # ← was has_loaded_game
	# Show main menu buttons again
	create_btn.show()
	join_btn.show()
	code_input.show()
	status_label.show()
