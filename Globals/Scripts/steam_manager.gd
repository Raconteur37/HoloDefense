extends Node

const APP_ID = 4758080

var steam_initialized: bool = false
var steam_id: int = 0
var steam_name: String = ""

var lobbyID: int = 0
var lobbyHost: String = ""
var opponentName: String = ""

signal lobby_join_status(success: bool)
signal lobby_members_updated()
signal opponent_left_lobby()
signal lobby_disconnected()
signal match_state_changed(new_state: String)
signal opponent_loadout_changed(slot: String, turret_name: String)    

func _ready() -> void:
	print("=== STEAM MANAGER READY ===")
	if not Engine.has_singleton("Steam"):
		push_error("Steam singleton not found!")
		return

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

	Steam.lobby_created.connect(_on_lobby_created)
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_data_update.connect(_on_lobby_data_update)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)


func _process(_delta: float) -> void:
	if steam_initialized:
		Steam.run_callbacks()


# --- Lobby lifecycle ---

func create_vs_lobby() -> void:
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 2)


func invite_user() -> void:
	if lobbyID == 0:
		push_warning("Cannot invite friends: No lobby has been created yet!")
		return
	Steam.activateGameOverlayInviteDialog(lobbyID)


func leaveLobby() -> void:
	if lobbyID == 0:
		push_warning("Attempted to leave lobby, but lobbyID is 0.")
		return

	print("Leaving lobby: ", lobbyID)
	Steam.leaveLobby(lobbyID)

	lobbyID = 0
	lobbyHost = ""
	opponentName = ""
	print("Successfully left the lobby.")


func advance_to_loadout() -> void:
	if lobbyID == 0:
		return
		
	var current_owner_id = Steam.getLobbyOwner(lobbyID)
	
	if current_owner_id != steam_id:
		print("Only the host can advance the state.")
		return # <-- The missing return has been added here
		
	Steam.setLobbyData(lobbyID, "match_state", "loadout")


func check_player_count() -> int:
	if lobbyID == 0:
		return 0
	return Steam.getNumLobbyMembers(lobbyID)


# --- Roster ---

func updateLobby() -> void:
	if lobbyID == 0:
		return

	if lobbyHost != steam_name and lobbyHost != "":
		opponentName = lobbyHost
		lobby_members_updated.emit()
		return

	opponentName = ""
	var numMembers = Steam.getNumLobbyMembers(lobbyID)
	for i in range(numMembers):
		var memberSteamId = Steam.getLobbyMemberByIndex(lobbyID, i)
		if memberSteamId != steam_id:
			opponentName = Steam.getFriendPersonaName(memberSteamId)

	lobby_members_updated.emit()


# --- Steam callbacks ---

func _on_lobby_created(connect_result: int, lobby_id: int) -> void:
	if connect_result == 1:
		lobbyID = lobby_id
		print("Successfully created lobby")

		Steam.setLobbyData(lobby_id, "lobby_name", "VS Lobby")
		Steam.setLobbyData(lobby_id, "lobby_host", steam_name)
		lobbyHost = steam_name

		updateLobby()
	else:
		print("Failed to create lobby. Error code: ", connect_result)


func _on_lobby_join_requested(lobby_id: int, _friend_id: int) -> void:
	Steam.joinLobby(lobby_id)


func _on_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == 1:
		lobbyID = lobby_id
		lobbyHost = Steam.getLobbyData(lobby_id, "lobby_host")

		var room_name = Steam.getLobbyData(lobby_id, "lobby_name")
		print("Joined room: ", room_name)

		lobby_join_status.emit(true)
		updateLobby()
	else:
		print("Failed to join lobby. Steam response code: ", response)
		lobby_join_status.emit(false)


func _on_lobby_data_update(success, lobby_id: int, member_id: int) -> void:
	if member_id == lobby_id:
		var currentState = Steam.getLobbyData(lobby_id, "match_state")
		if currentState != "":
			match_state_changed.emit(currentState)
			
	elif member_id != steam_id:
		# Added "loadout_list" to the end here just in case you use the array method
		var slots_to_check = ["slot_1", "slot_2", "slot_3", "slot_4", "slot_5", "slot_6", "slot_7", "slot_8", "slot_9", "slot_10", "loadout_list"]
		
		for slot in slots_to_check:
			var opponentTurret = Steam.getLobbyMemberData(lobby_id, member_id, slot)
			if opponentTurret != "":
				opponent_loadout_changed.emit(slot, opponentTurret)


func _on_lobby_chat_update(lobby_id: int, changed_id: int, _making_change_id: int, chat_state: int) -> void:
	if chat_state & Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		updateLobby()
		return

	var left_mask = Steam.CHAT_MEMBER_STATE_CHANGE_LEFT \
		| Steam.CHAT_MEMBER_STATE_CHANGE_DISCONNECTED \
		| Steam.CHAT_MEMBER_STATE_CHANGE_KICKED \
		| Steam.CHAT_MEMBER_STATE_CHANGE_BANNED

	if chat_state & left_mask:
		if changed_id == steam_id:
			lobbyID = 0
			lobbyHost = ""
			opponentName = ""
			lobby_disconnected.emit()
		else:
			opponentName = ""
			opponent_left_lobby.emit()
			updateLobby()


# --- Loadout Management ---

func set_loadout_slot(slot_name: String, turret_name: String) -> void:
	if lobbyID == 0:
		return
		
	Steam.setLobbyMemberData(lobbyID, slot_name, turret_name)


func add_turret_to_loadout(turret_name: String) -> void:
	if lobbyID == 0:
		return
		
	var current_loadout = Steam.getLobbyMemberData(lobbyID, steam_id, "loadout_list")
	
	if current_loadout == "":
		current_loadout = turret_name
	else:
		current_loadout += "," + turret_name
		
	Steam.setLobbyMemberData(lobbyID, "loadout_list", current_loadout)
