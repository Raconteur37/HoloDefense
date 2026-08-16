extends Node

@onready var popup = preload("res://Globals/Scene/Popup.tscn")

@onready var commanderPopup = preload("res://Game Scenes/CommanderPopup.tscn")

var activeCaptainPopup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func getPopupParent() -> Node:
	var gameNode = get_tree().root.find_child("Game", true, false)
	if gameNode:
		return gameNode
	return get_tree().current_scene

func eventNotify():
	if activeCaptainPopup != null:
		activeCaptainPopup.queue_free()
	var commandPopup = commanderPopup.instantiate()
	getPopupParent().add_child(commandPopup)
	commandPopup.msg = "Commander, in this current system there is a " + str(WaveManager.getEventChance(WaveManager.currentDifficulty)) + "% chance an abnormality will occur."
	if WaveManager.currentDifficulty >= 9:
		commandPopup.msg += "\nSince we are in a very hostile System, this chance is increasing dramatrically each wave."
	commandPopup.expression = "speaking"
	commandPopup.time = 8

func eventPopup(event : String):
	if activeCaptainPopup != null:
		activeCaptainPopup.queue_free()
	var commandPopup = commanderPopup.instantiate()
	getPopupParent().add_child(commandPopup)
	commandPopup.expression = "urgent"
	commandPopup.time = 8
	if event.to_lower() == "boss":
		commandPopup.msg = "Commander, an unscheduled boss has appeared in this system, we must do something."
	if event.to_lower() == "rift":
		commandPopup.msg = "Commander, a rift has opened in our defense grid, I will work with you to dael with it."
	if event.to_lower() == "formation":
		commandPopup.msg = "Commander, the shapes are developing formation tactics, I advise we do the same."

func systemFinishPopup():
	if activeCaptainPopup != null:
		activeCaptainPopup.queue_free()
	var commandPopup = commanderPopup.instantiate()
	getPopupParent().add_child(commandPopup)
	commandPopup.expression = "happy"
	commandPopup.time = 6
	if WaveManager.currentDifficulty <= 4:
		var msgs = ["Great job Commander, let's keep going.","That was though, glad we made it through!\n Onto the next.","System completed, prepping the city for the next system."]
		commandPopup.msg = msgs.pick_random()
		return
	if WaveManager.currentDifficulty <= 8:
		var msgs = ["This hasn't been easy Commander, we appreciate your work.","We haven't made it yet, but with your guidance I know we will.","Your coordination is impeccable, it inspires us all."]
		commandPopup.msg = msgs.pick_random()
		return
	if WaveManager.currentDifficulty <= 11:
		var msgs = ["That was close.....I'm motivating the team now to keep going.\n We are unstoppable Commander.","Your lust for the stars is inspiring, we are counting on you.","With you as our Commander there is no waning, only driven success."]
		commandPopup.msg = msgs.pick_random()
		return

func losingPopup():
	if activeCaptainPopup != null:
		activeCaptainPopup.queue_free()
	await get_tree().create_timer(randi_range(5,11)).timeout
	var commandPopup = commanderPopup.instantiate()
	getPopupParent().add_child(commandPopup)
	commandPopup.expression = "default"
	commandPopup.time = 9
	var msgs = ["We try again, this is the only way.","I thought we had it.......I'm rebooting the city now and counting our losses...we go again.","There was nothing we could have done there Commander, reestablish and try again.",
	"We cannot let this deter us from reaching the end, we must find the courage to go again."]
	commandPopup.msg = msgs.pick_random()

func systemStartPopup():
	await get_tree().create_timer(randi_range(6,12)).timeout
	var commandPopup = commanderPopup.instantiate()
	getPopupParent().add_child(commandPopup)
	commandPopup.expression = "speaking"
	commandPopup.time = 8
	var msgs = ["Goodluck Commander, we know we are in good hands.","I'm right by your side Commander, lets make it to the end.","The city has never been more ready, let's finish it this time.","We all believe in you Commander, don't let us down."]
	commandPopup.msg = msgs.pick_random()

func idleWorkerPopup():
	if activeCaptainPopup == null:
		var commandPopup = commanderPopup.instantiate()
		getPopupParent().add_child(commandPopup)
		commandPopup.expression = "speaking"
		commandPopup.time = 8
		commandPopup.msg = "Commander, we have idle workers, if you don't assign them to something, I will."

func clearCaptainPopups():
	if activeCaptainPopup != null:
		activeCaptainPopup.queue_free()
		activeCaptainPopup = null

func soloNotify():
	if activeCaptainPopup == null:
		var commandPopup = commanderPopup.instantiate()
		getPopupParent().add_child(commandPopup)
		commandPopup.expression = "speaking"
		commandPopup.time = 8
		commandPopup.msg = "Setup the parameters before we begin our journey."
		commandPopup.get_child(0).global_position.x += 30
		commandPopup.get_child(0).global_position.y += 75

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
