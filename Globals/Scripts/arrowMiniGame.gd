class_name ArrowMinigame
extends Node

signal success
signal failed

var inputSequence : Array = []
var currentIndex : int = 0
var sequenceLength : int = 5

const DIRECTIONS = ["up", "down", "left", "right"]

var arrowEmpty : Dictionary = {}
var arrowFilled : Dictionary = {}
var textures : Array = []

func _ready() -> void:
	arrowEmpty = {
		"up":    preload("res://Textures/Holo City/arrow_up_empty.svg"),
		"down":  preload("res://Textures/Holo City/arrow_down_empty.svg"),
		"left":  preload("res://Textures/Holo City/arrow_left_empty.svg"),
		"right": preload("res://Textures/Holo City/arrow_right_empty.svg"),
	}
	arrowFilled = {
		"up":    preload("res://Textures/Holo City/arrow_up_filled.svg"),
		"down":  preload("res://Textures/Holo City/arrow_down_filled.svg"),
		"left":  preload("res://Textures/Holo City/arrow_left_filled.svg"),
		"right": preload("res://Textures/Holo City/arrow_right_filled.svg"),
	}

func setup(textureNodes: Array, length: int = 5) -> void:
	textures = textureNodes
	sequenceLength = length

func start() -> void:
	inputSequence.clear()
	currentIndex = 0

	# Disconnect any previous minigame's listener
	if MinigameManager.currentMinigame and MinigameManager.currentMinigame != self:
		if MinigameManager.direction_pressed.is_connected(MinigameManager.currentMinigame._handleInput):
			MinigameManager.direction_pressed.disconnect(MinigameManager.currentMinigame._handleInput)

	MinigameManager.currentMinigame = self
	if not MinigameManager.direction_pressed.is_connected(_handleInput):
		MinigameManager.direction_pressed.connect(_handleInput)

	MinigameManager.active = true
	for i in range(sequenceLength):
		inputSequence.append(DIRECTIONS[randi() % DIRECTIONS.size()])
	_refreshDisplay()

func stop() -> void:
	if MinigameManager.direction_pressed.is_connected(_handleInput):
		MinigameManager.direction_pressed.disconnect(_handleInput)
	if MinigameManager.currentMinigame == self:
		MinigameManager.currentMinigame = null
	MinigameManager.active = false

func _refreshDisplay() -> void:
	for i in range(sequenceLength):
		var dir = inputSequence[i]
		if i < currentIndex:
			textures[i].texture = arrowFilled[dir]
		else:
			textures[i].texture = arrowEmpty[dir]

func _handleInput(dir: String) -> void:
	if not MinigameManager.active:
		return

	if dir == inputSequence[currentIndex]:
		textures[currentIndex].texture = arrowFilled[dir]
		currentIndex += 1
		if currentIndex >= sequenceLength:
			stop()
			success.emit()
			SoundManager.playManualGenSound(2)
		else:
			SoundManager.playManualGenSound(1)
	else:
		_onFail()

func _onFail() -> void:
	currentIndex = 0
	for t in textures:
		t.modulate = Color.RED
	SoundManager.playManualGenSound(3)
	MinigameManager.active = false
	await get_tree().create_timer(0.4).timeout
	MinigameManager.active = true
	for t in textures:
		t.modulate = Color.WHITE
	_refreshDisplay()
	failed.emit()
