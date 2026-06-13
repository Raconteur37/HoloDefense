extends Node

signal direction_pressed(dir: String)

var active : bool = false
var currentMinigame : ArrowMinigame = null

var _dirWasDown : Dictionary = {
	"up": false, "down": false, "left": false, "right": false
}

func _process(_delta: float) -> void:
	if not active:
		return

	_checkDir("up",    [KEY_UP, KEY_W])
	_checkDir("down",  [KEY_DOWN, KEY_S])
	_checkDir("left",  [KEY_LEFT, KEY_A])
	_checkDir("right", [KEY_RIGHT, KEY_D])

func _checkDir(dir: String, keycodes: Array) -> void:
	var isDown = false
	for k in keycodes:
		if Input.is_physical_key_pressed(k):
			isDown = true
			break

	if isDown and not _dirWasDown[dir]:
		direction_pressed.emit(dir)

	_dirWasDown[dir] = isDown
