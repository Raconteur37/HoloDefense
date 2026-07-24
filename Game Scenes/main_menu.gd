extends Control

@onready var soloFrame = $"Solo Frame"

func _ready() -> void:
	Engine.time_scale = 1
	if not SettingsManager.is_tutorial_done():
		get_tree().change_scene_to_file("res://Game Scenes/Tutorial Scene.tscn")
