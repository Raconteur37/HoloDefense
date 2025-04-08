extends Control

var citizenGenGrid : GridContainer

func _ready():
	citizenGenGrid = $CitizenGenerateGrid

func _on_texture_button_pressed() -> void:
	# Check cost and all that
	
	var genScene = load("res://Game Scenes/HoloCitizenGenerationScene.tscn")
	var loadedScene = genScene.instantiate()
	citizenGenGrid.add_child(loadedScene)
