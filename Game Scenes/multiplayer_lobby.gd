extends Control

@onready var create_btn   = $CreateButton
@onready var join_btn     = $JoinButton
@onready var code_input   = $CodeInput
@onready var port_input   = $PortInput
@onready var status_label = $StatusLabel
@onready var code_display = $CodeLabel

# Lobby nodes (add these to your scene, hidden by default)
@onready var lobby_panel  = $LobbyPanel
@onready var player_list  = $LobbyPanel/PlayerList
@onready var room_label   = $LobbyPanel/RoomLabel
@onready var start_btn    = $LobbyPanel/StartButton

func _ready():
	NetworkManager.server_created.connect(_on_server_created)
	NetworkManager.connection_succeeded.connect(_on_connected)
	NetworkManager.connection_failed.connect(_on_connect_failed)
	NetworkManager.player_connected.connect(_refresh_players)
	NetworkManager.player_disconnected.connect(_refresh_players)

	port_input.text = "7777"
	code_display.hide()
	lobby_panel.hide()


func _on_create_button_pressed():
	var port = int(port_input.text)
	var err = NetworkManager.create_server(port)
	if err == OK:
		status_label.text = "Hosting..."
	else:
		status_label.text = "Failed to host (port in use?)"


func _on_join_button_pressed():
	var code = code_input.text.strip_edges().to_upper()
	if code.length() < 8:
		status_label.text = "Enter a valid code"
		return
	status_label.text = "Connecting..."
	var err = NetworkManager.join_server(code)
	if err != OK:
		status_label.text = "Connection error"


func _on_server_created(code: String):
	code_display.text = "Room Code: %s" % code
	code_display.show()
	_show_lobby()


func _on_connected():
	_show_lobby()


func _on_connect_failed():
	status_label.text = "Failed to connect. Check the code."


func _show_lobby():
	lobby_panel.show()

	if NetworkManager.is_host():
		room_label.text = "Room Code: " + NetworkManager.room_code
		start_btn.show()
	else:
		room_label.text = "Joined: " + NetworkManager.room_code
		start_btn.hide()

	_refresh_players(0, {})


func _refresh_players(_id, _data):
	player_list.clear()
	for id in NetworkManager.players:
		var pdata = NetworkManager.players[id]
		player_list.add_item("%s (ID: %d)" % [pdata.get("name", "?"), id])


func _on_start_button_pressed():
	if NetworkManager.is_host():
		start_game.rpc()


# In your lobby _on_start_button_pressed or _start_game RPC
@rpc("authority", "call_local", "reliable")
func start_game():
	GameManager.VSmode = true        # ← set this before loading
	get_tree().change_scene_to_file("res://Game Scenes/Loadout.tscn")
