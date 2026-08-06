extends Node

const APP_ID = 4758080

var steam_initialized : bool = false
var steam_id : int = 0
var steam_name : String = ""

var lobbyID : int
var lobbyHost : String

var opponentName : String

signal lobby_join_status(success: bool)
signal lobby_members_updated()
signal opponent_left_lobby()
signal lobby_disconnected()

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
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)


func _process(_delta: float) -> void:
	if steam_initialized:
		Steam.run_callbacks()

func create_vs_lobby():
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 2)

func _on_lobby_created(connect_result: int, lobby_id: int):
	if connect_result == 1:
		lobbyID = lobby_id
		print("Successfully created lobby")
		
		Steam.setLobbyData(lobby_id, "lobby_name", "VS Lobby")
		Steam.setLobbyData(lobby_id, "lobby_host", steam_name)
		lobbyHost = steam_name
		
		updateLobby()
		
	else:
		print("Failed to create lobby. Error code: ", connect_result)

func invite_user():
	if lobbyID == 0:
		push_warning("Cannot invite friends: No lobby has been created yet!")
		return
		
	Steam.activateGameOverlayInviteDialog(lobbyID)


func _on_lobby_join_requested(lobby_id: int, friend_id: int) -> void:
	Steam.joinLobby(lobby_id)


func _on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	if response == 1:
		lobbyID = lobby_id
		lobbyHost = Steam.getLobbyData(lobby_id, "lobby_host")
		
		var room_name = Steam.getLobbyData(lobby_id, "lobby_name")
		print("Joined room: ", room_name)
		
		var host_id = Steam.getLobbyOwner(lobby_id)
		lobby_join_status.emit(true)
		
		updateLobby()
	else:
		print("Failed to join lobby. Steam response code: ", response)
		lobby_join_status.emit(false)

func leaveLobby():
	if lobbyID == 0:
		push_warning("Attempted to leave lobby, but lobbyID is 0.")
		return
		
	print("Leaving lobby: ", lobbyID)
	Steam.leaveLobby(lobbyID)
	
	lobbyID = 0
	lobbyHost = ""
	opponentName = ""
	
	print("Successfully left the lobby.")

func updateLobby() -> void:
	if lobbyID == 0:
		return
		
	opponentName = ""
	
	var num_members = Steam.getNumLobbyMembers(lobbyID)
	
	for i in range(num_members):
		var member_steam_id = Steam.getLobbyMemberByIndex(lobbyID, i)
		
		if member_steam_id != steam_id:
			opponentName = Steam.getFriendPersonaName(member_steam_id)
			
	lobby_members_updated.emit()


func _on_lobby_chat_update(lobby_id: int, changed_id: int, making_change_id: int, chat_state: int) -> void:
	
	if chat_state == 2 or chat_state == 4 or chat_state == 8:
		print("The opponent left or disconnected. Destroying lobby.")
		
		leaveLobby()
		
		lobby_disconnected.emit()
	else:
		updateLobby()
