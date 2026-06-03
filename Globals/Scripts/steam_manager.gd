extends Node

const APP_ID = 4758080  # ← your actual app ID

var steam_initialized: bool = false
var steam_id: int = 0
var steam_name: String = ""
var current_lobby_id: int = 0

signal lobby_created(lobby_id)
signal lobby_joined(lobby_id)
signal lobby_join_failed()
signal lobby_members_updated()
signal friend_invite_accepted(lobby_id)

func _ready() -> void:
	print("=== STEAM MANAGER READY ===")

	if not Engine.has_singleton("Steam"):
		push_error("Steam singleton not found!")
		return

	print("Has Steam singleton: ", Engine.has_singleton("Steam"))

	OS.set_environment("SteamAppId", str(APP_ID))

	var init = Steam.steamInitEx(false)
	print("Init result: ", init)

	if init["status"] != Steam.STEAM_API_INIT_RESULT_OK:
		push_error("Steam failed to initialize: " + str(init))
		return

	steam_initialized = true
	steam_id = Steam.getSteamID()
	steam_name = Steam.getPersonaName()
	print("Steam initialized as: %s (%d)" % [steam_name, steam_id])

	# Connect all lobby + invite signals
	Steam.lobby_joined.connect(_on_lobby_entered)
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_chat_update.connect(_on_lobby_members_changed)


func _process(_delta: float) -> void:
	if steam_initialized:
		Steam.run_callbacks()


# ─────────────────────────────────────────
#  CREATE LOBBY
# ─────────────────────────────────────────

func create_lobby() -> void:
	if not steam_initialized:
		return
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 8)


func _on_lobby_created(result: int, lobby_id: int) -> void:
	if result != 1:
		push_error("Lobby creation failed: %d" % result)
		return

	current_lobby_id = lobby_id
	Steam.setLobbyData(lobby_id, "game", str(APP_ID))
	Steam.setLobbyData(lobby_id, "state", "waiting")

	print("Lobby created: ", lobby_id)
	lobby_created.emit(lobby_id)


# ─────────────────────────────────────────
#  JOIN LOBBY
# ─────────────────────────────────────────

func join_lobby(lobby_id: int) -> void:
	if not steam_initialized:
		return
	Steam.joinLobby(lobby_id)


func join_lobby_by_code(code: String) -> void:
	var lobby_id = int(code.strip_edges())
	if lobby_id == 0:
		lobby_join_failed.emit()
		return
	join_lobby(lobby_id)


func _on_lobby_entered(lobby_id: int, response: int) -> void:
	if response != 1:
		push_error("Failed to join lobby: %d" % response)
		lobby_join_failed.emit()
		return

	current_lobby_id = lobby_id
	print("Joined lobby: ", lobby_id)
	lobby_joined.emit(lobby_id)


# ─────────────────────────────────────────
#  MEMBERS
# ─────────────────────────────────────────

func _on_lobby_members_changed(lobby_id: int, _steam_id: int, _making_change: int, _chat_change: int) -> void:
	lobby_members_updated.emit()


func get_lobby_members() -> Array:
	if current_lobby_id == 0:
		return []
	var members = []
	var count = Steam.getNumLobbyMembers(current_lobby_id)
	for i in range(count):
		var member_id = Steam.getLobbyMemberByIndex(current_lobby_id, i)
		members.append({
			"steam_id": member_id,
			"name": Steam.getFriendPersonaName(member_id)
		})
	return members


func is_host() -> bool:
	if current_lobby_id == 0:
		return false
	return Steam.getLobbyOwner(current_lobby_id) == steam_id


# ─────────────────────────────────────────
#  INVITES
# ─────────────────────────────────────────

# Opens the Steam overlay friend invite dialog
func open_invite_overlay() -> void:
	if current_lobby_id == 0:
		push_error("No lobby to invite to")
		return
	Steam.activateGameOverlayInviteDialog(current_lobby_id)


# Friend clicked "Join Game" on your Steam profile or accepted an invite
func _on_lobby_join_requested(lobby_id: int, _friend_id: int) -> void:
	print("Join requested via Steam overlay for lobby: ", lobby_id)
	join_lobby(lobby_id)
	friend_invite_accepted.emit(lobby_id)


# Handles +connect launch argument when game is launched from invite
func _on_game_join_requested(lobby_id: int, _steam_id: int) -> void:
	print("Game join requested for lobby: ", lobby_id)
	join_lobby(lobby_id)
	friend_invite_accepted.emit(lobby_id)


# ─────────────────────────────────────────
#  LEAVE LOBBY
# ─────────────────────────────────────────

func leave_lobby() -> void:
	if current_lobby_id != 0:
		Steam.leaveLobby(current_lobby_id)
		current_lobby_id = 0
