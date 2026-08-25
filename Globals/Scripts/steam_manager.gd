extends Node

const APP_ID = 4758080

var multiplayer_peer: SteamMultiplayerPeer

var steam_initialized: bool = false
var steam_id: int = 0
var steam_name: String = ""

var lobbyID: int = 0
var lobbyHost: String = ""
var opponentName: String = ""

var vs_match_won: bool = false

# Track states to prevent signal spam
var current_match_state: String = ""
var current_difficulty: float = -1.0

var is_local_ready: bool = false
var is_opponent_ready: bool = false

signal lobby_join_status(success: bool)
signal lobby_members_updated()
signal opponent_left_lobby()
signal lobby_disconnected()
signal match_state_changed(new_state: String)
signal opponent_loadout_changed(slot: String, turret_name: String)
signal difficulty_changed(new_diff: float)

func _ready() -> void:
	print("=== STEAM MANAGER READY ===")
	if not Engine.has_singleton("Steam"):
		push_error("Steam singleton not found!")
		return

	OS.set_environment("SteamAppId", str(APP_ID))
	var init = Steam.steamInitEx(false)
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
		return
	Steam.activateGameOverlayInviteDialog(lobbyID)

func leaveLobby() -> void:
	if lobbyID == 0:
		return

	Steam.leaveLobby(lobbyID)
	lobbyID = 0
	lobbyHost = ""
	opponentName = ""
	current_match_state = ""
	current_difficulty = -1.0

	multiplayer.multiplayer_peer = null
	multiplayer_peer = null

func advance_to_loadout() -> void:
	if lobbyID == 0:
		return
	var current_owner_id = Steam.getLobbyOwner(lobbyID)
	if current_owner_id != steam_id:
		return
		
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


func get_opponent_id() -> int:
	if lobbyID == 0:
		return 0

	var numMembers = Steam.getNumLobbyMembers(lobbyID)
	for i in range(numMembers):
		var memberSteamId = Steam.getLobbyMemberByIndex(lobbyID, i)
		if memberSteamId != steam_id:
			return memberSteamId

	return 0

# --- Steam callbacks ---

func _on_lobby_created(connect_result: int, lobby_id: int) -> void:
	if connect_result == 1:
		lobbyID = lobby_id
		Steam.setLobbyData(lobby_id, "lobby_name", "VS Lobby")
		Steam.setLobbyData(lobby_id, "lobby_host", steam_name)
		lobbyHost = steam_name
		
		multiplayer_peer = SteamMultiplayerPeer.new()
		multiplayer_peer.create_host(0)
		multiplayer.multiplayer_peer = multiplayer_peer
		
		updateLobby()

func _on_lobby_join_requested(lobby_id: int, _friend_id: int) -> void:
	Steam.joinLobby(lobby_id)

func _on_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == 1:
		lobbyID = lobby_id
		lobbyHost = Steam.getLobbyData(lobby_id, "lobby_host")
		GameManager.VSmode = true
		lobby_join_status.emit(true)
		
		var host_id = Steam.getLobbyOwner(lobby_id)
		if host_id != steam_id:
			multiplayer_peer = SteamMultiplayerPeer.new()
			
			multiplayer_peer.create_client(host_id, 0)
			
			multiplayer.multiplayer_peer = multiplayer_peer
		
		updateLobby()
	else:
		lobby_join_status.emit(false)

func _on_lobby_data_update(success, lobby_id: int, member_id: int) -> void:
	# 1. Global Room Updates (Match State & Difficulty)
	if member_id == lobby_id:
		var updated_state = Steam.getLobbyData(lobby_id, "match_state")
		if updated_state != "" and updated_state != current_match_state:
			current_match_state = updated_state
			match_state_changed.emit(current_match_state)
			
		var updated_diff_str = Steam.getLobbyData(lobby_id, "difficulty")
		if updated_diff_str != "":
			var updated_diff = updated_diff_str.to_float()
			if updated_diff != current_difficulty:
				current_difficulty = updated_diff
				difficulty_changed.emit(current_difficulty)
				
	# 2. Player Data Updates (Loadouts)
	elif member_id != steam_id:
		var slots_to_check = ["slot_1", "slot_2", "slot_3", "slot_4", "slot_5", "slot_6", "slot_7", "slot_8", "slot_9", "slot_10", "loadout_list", "is_ready"]
		
		for slot in slots_to_check:
			var opponentData = Steam.getLobbyMemberData(lobby_id, member_id, slot)
			if opponentData != "":
				opponent_loadout_changed.emit(slot, opponentData)

func _on_lobby_chat_update(lobby_id: int, changed_id: int, _making_change_id: int, chat_state: int) -> void:
	if chat_state & Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		updateLobby()
		return

	var left_mask = Steam.CHAT_MEMBER_STATE_CHANGE_LEFT | Steam.CHAT_MEMBER_STATE_CHANGE_DISCONNECTED | Steam.CHAT_MEMBER_STATE_CHANGE_KICKED | Steam.CHAT_MEMBER_STATE_CHANGE_BANNED
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


func set_loadout_slot(slot_name: String, data: String) -> void:
	if lobbyID == 0:
		return
	Steam.setLobbyMemberData(lobbyID, slot_name, data)

func add_turret_to_loadout(turret_name: String) -> void:
	if lobbyID == 0:
		return
	var current_loadout = Steam.getLobbyMemberData(lobbyID, steam_id, "loadout_list")
	if current_loadout == "":
		current_loadout = turret_name
	else:
		current_loadout += "," + turret_name
	Steam.setLobbyMemberData(lobbyID, "loadout_list", current_loadout)



func sendWave(wave_data: Array) -> void:
	var connected_peers = multiplayer.get_peers()
	
	if connected_peers.is_empty():
		push_error("EnemySynth: Nobody is connected to the P2P network!")
		return
		
	var target_godot_peer = connected_peers[0]
	
	receiveWave.rpc_id(target_godot_peer, wave_data)

@rpc("any_peer", "reliable")
func receiveWave(wave_data: Array) -> void:
	var sender = multiplayer.get_remote_sender_id()
	if sender == multiplayer.get_unique_id():
		return
		
	var holder = get_tree().current_scene.find_child("EnemyNodeHolder")
	if not holder:
		return
		
	for spawn_info in wave_data:
		var id = spawn_info["id"] as Enemy.EnemyID
		var e_type = spawn_info["elite"] as Enemy.EliteType
		var amount = spawn_info["amount"] as int
		
		if not EnemySpawnManager.ENEMIES.has(id):
			continue
			
		for i in range(amount):
			var enemy = EnemySpawnManager.ENEMIES[id].instantiate()
			enemy.is_sent_enemy = true
			
			holder.add_child(enemy)
			
			if e_type != Enemy.EliteType.NONE:
				enemy.type = Enemy.Type.ELITE
				enemy.isElite = true
				enemy.eliteType = e_type
				enemy.setElite()
				
			enemy.global_position = EnemySpawnManager.getRandomOffscreenPosition()
			WaveManager.registerActiveEnemy(enemy)
			
			if enemy.has_method("getDestination"):
				enemy.getDestination()

func send_player_died() -> void:
	var connected_peers = multiplayer.get_peers()
	if connected_peers.is_empty():
		return
		
	var target_godot_peer = connected_peers[0]
	receive_opponent_died.rpc_id(target_godot_peer)

@rpc("any_peer", "reliable")
func receive_opponent_died() -> void:
	var sender = multiplayer.get_remote_sender_id()
	if sender == multiplayer.get_unique_id():
		return
	
	get_tree().change_scene_to_file("res://Game Scenes/RewardScene.tscn")
