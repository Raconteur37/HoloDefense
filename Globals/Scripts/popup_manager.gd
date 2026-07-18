extends Node

@onready var popup = preload("res://Globals/Scene/Popup.tscn")

@onready var commanderPopup = preload("res://Game Scenes/CommanderPopup.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func eventNotify():
	var commandPopup = commanderPopup.instantiate()
	get_tree().current_scene.add_child(commandPopup)
	commandPopup.msg = "Commander, in this current system there is a " + str(WaveManager.getEventChance(WaveManager.currentDifficulty)) + "% chance an abnormality will occur."
	if WaveManager.currentDifficulty >= 8:
		commanderPopup.msg += "\nSince we are in a very hostile System, this chance is increasing dramatrically each wave."
	commandPopup.expression = "speaking"
	commandPopup.time = 8

func eventPopup(event : String):
	var commandPopup = commanderPopup.instantiate()
	get_tree().current_scene.add_child(commandPopup)
	commandPopup.expression = "urgent"
	commandPopup.time = 8
	if event.to_lower() == "boss":
		commandPopup.msg = "Commander, an unscheduled boss has appeared in this system, we must do something."
	if event.to_lower() == "rift":
		commandPopup.msg = "Commander, a rift has opened in our defense grid, I will work with you to dael with it."
	if event.to_lower() == "formation":
		commandPopup.msg = "Commander, the shapes are developing formation tactics, I advise we do the same."



func enemiesIncomingPopup(timeRemaining):
	var popScene = popup.instantiate()
	var canvasLayer
	
	if get_tree().current_scene is not CanvasLayer:
		for child in get_tree().current_scene.get_children():
			if child is CanvasLayer:
				canvasLayer = child
				break
	else:
		canvasLayer = get_tree().current_scene
		
	canvasLayer.add_child(popScene)
	popScene.timeRemainingAlert(timeRemaining)
