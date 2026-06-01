extends Control

const PORT = 8910
var peer = ENetMultiplayerPeer.new()
var roomCode = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_create_button_pressed() -> void:
	createRoom()

func createRoom():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	print("Room created as self on port: {" + str(PORT) + "}")

func generateRoomCode():
	pass
