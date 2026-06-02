extends Node

# Add this as an autoload singleton named "NetworkManager"

const DEFAULT_PORT = 7777
const MAX_PLAYERS = 2

var room_code: String = ""
var player_id: int = 0
var players: Dictionary = {}  # peer_id -> player_data

signal player_connected(id, data)
signal player_disconnected(id)
signal connection_failed()
signal connection_succeeded()
signal server_created(code)

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_server(port: int = DEFAULT_PORT) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, MAX_PLAYERS)
	if err != OK:
		push_error("Failed to create server: %s" % err)
		return err

	multiplayer.multiplayer_peer = peer
	player_id = 1  # Host is always peer 1

	# Register host's own data
	players[1] = _local_player_data()

	# Generate a room code from the port (or use relay logic)
	room_code = RoomCode.encode(port)
	server_created.emit(room_code)
	print("Server started on port %d | Code: %s" % [port, room_code])
	return OK


func join_server(code: String) -> Error:
	var decoded = RoomCode.decode(code)
	if decoded.is_empty():
		push_error("Invalid room code")
		return ERR_INVALID_PARAMETER

	var ip: String = decoded["ip"]
	var port: int   = decoded["port"]
	return _connect_to(ip, port)


func join_by_ip(ip: String, port: int = DEFAULT_PORT) -> Error:
	return _connect_to(ip, port)


func _connect_to(ip: String, port: int) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, port)
	if err != OK:
		push_error("Failed to connect: %s" % err)
		return err

	multiplayer.multiplayer_peer = peer
	return OK



func disconnect_from_game():
	players.clear()
	room_code = ""
	multiplayer.multiplayer_peer = null


@rpc("any_peer", "reliable")
func register_player(data: Dictionary):
	var sender_id = multiplayer.get_remote_sender_id()
	players[sender_id] = data
	player_connected.emit(sender_id, data)

	# If we're the server, broadcast the full player list back
	if multiplayer.is_server():
		_sync_all_players.rpc(players)


@rpc("authority", "reliable")
func _sync_all_players(all_players: Dictionary):
	players = all_players
	for id in players:
		if id != multiplayer.get_unique_id():
			player_connected.emit(id, players[id])



func _on_peer_connected(id: int):
	print("Peer connected: ", id)
	# New peer joined — send them our data
	register_player.rpc_id(id, _local_player_data())


func _on_peer_disconnected(id: int):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_to_server():
	player_id = multiplayer.get_unique_id()
	players[player_id] = _local_player_data()
	# Send our data to the host
	register_player.rpc_id(1, _local_player_data())
	connection_succeeded.emit()


func _on_connection_failed():
	multiplayer.multiplayer_peer = null
	connection_failed.emit()


func _on_server_disconnected():
	disconnect_from_game()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _local_player_data() -> Dictionary:
	return {
		"name": OS.get_environment("USERNAME") if OS.get_environment("USERNAME") != "" else "Player",
		"id": multiplayer.get_unique_id()
	}

func is_host() -> bool:
	return multiplayer.is_server()
