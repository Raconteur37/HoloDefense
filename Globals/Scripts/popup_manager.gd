extends Node

@onready var popup = preload("res://Globals/Scene/Popup.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
