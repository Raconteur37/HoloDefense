extends Node

const APP_ID = 4758080

var steam_initialized: bool = false
var steam_id: int = 0
var steam_name: String = ""
var current_lobby_id: int = 0

signal lobby_created(lobby_id)
signal lobby_joined(lobby_id)
signal lobby_join_failed()
signal lobby_members_updated()
signal friend_invite_accepted(lobby_id)
signal player_joined_lobby()

signal enemy_received(enemy_id)

func _ready() -> void:
	print("=== STEAM MANAGER READY ===")

	if not Engine.has_singleton("Steam"):
		push_error("Steam singleton not found!")
		return

	Steam.p2p_session_request.connect(_on_p2p_session_request)
	Steam.p2p_session_connect_fail.connect(_on_p2p_session_fail)

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

	# Connect all signals
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_entered)
	Steam.lobby_chat_update.connect(_on_lobby_members_changed)
	Steam.join_requested.connect(_on_lobby_join_requested)

	# Check if game was launched directly from a Steam invite
	_check_launch_command_line()


func _process(_delta: float) -> void:
	if steam_initialized:
		Steam.run_callbacks()
		_read_p2p_messages()  # ← add this


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
	player_joined_lobby.emit()


# ─────────────────────────────────────────
#  MEMBERS
# ─────────────────────────────────────────

func _on_lobby_members_changed(_lobby_id: int, _steam_id: int, _making_change: int, _chat_change: int) -> void:
	print("Lobby members changed")
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

func open_invite_overlay() -> void:
	if current_lobby_id == 0:
		push_error("No lobby to invite to")
		return
	Steam.activateGameOverlayInviteDialog(current_lobby_id)


# Friend accepted invite via Steam overlay
func _on_lobby_join_requested(lobby_id: int, _friend_id: int) -> void:
	print("Join requested via Steam overlay for lobby: ", lobby_id)
	join_lobby(lobby_id)
	friend_invite_accepted.emit(lobby_id)


# Game launched fresh from a Steam invite link
func _check_launch_command_line() -> void:
	var args = OS.get_cmdline_args()
	print("Launch args: ", args)
	for arg in args:
		if "+connect_lobby" in arg:
			var parts = arg.split(" ")
			if parts.size() >= 2:
				var lobby_id = int(parts[1])
				print("Launched from invite, joining lobby: ", lobby_id)
				# Wait longer for the main menu scene to fully load
				await get_tree().create_timer(2.0).timeout
				join_lobby(lobby_id)
				friend_invite_accepted.emit(lobby_id)
			return

# ─────────────────────────────────────────
#  LEAVE LOBBY
# ─────────────────────────────────────────

func leave_lobby() -> void:
	if current_lobby_id != 0:
		Steam.leaveLobby(current_lobby_id)
		current_lobby_id = 0
		print("Left lobby")

# ─────────────────────────────────────────
#  P2P MESSAGING
# ─────────────────────────────────────────

func _on_p2p_session_request(remote_steam_id: int) -> void:
	# Accept connection from any lobby member
	var members = get_lobby_members()
	for member in members:
		if member["steam_id"] == remote_steam_id:
			Steam.acceptP2PSessionWithUser(remote_steam_id)
			return


func _on_p2p_session_fail(steam_id: int, error: int) -> void:
	push_error("P2P session failed with %d: %d" % [steam_id, error])


func send_enemy_to(target_steam_id: int, enemy_id: int) -> void:
	# Pack the message: just the enemy ID as a single byte
	var data = PackedByteArray([enemy_id])
	Steam.sendP2PPacket(target_steam_id, data, Steam.P2P_SEND_RELIABLE, 0)


func _read_p2p_messages() -> void:
	# Check for incoming packets every frame
	var packet_size = Steam.getAvailableP2PPacketSize(0)
	while packet_size > 0:
		var packet = Steam.readP2PPacket(packet_size, 0)
		if packet.is_empty():
			break
		var enemy_id = packet["data"][0]
		enemy_received.emit(enemy_id)
		packet_size = Steam.getAvailableP2PPacketSize(0)


func get_opponent_steam_ids() -> Array:
	var opponents = []
	for member in get_lobby_members():
		if member["steam_id"] != steam_id:
			opponents.append(member["steam_id"])
	return opponents
