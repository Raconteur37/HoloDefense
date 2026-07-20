extends Control

func _ready() -> void:
	Engine.time_scale = 1
	if not SettingsManager.is_tutorial_done():
		get_tree().change_scene_to_file("res://Game Scenes/Tutorial Scene.tscn")

func _on_solo_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Loadout.tscn")


func _on_multiplayer_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Multiplayer Lobby.tscn")


func _on_turrets_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Turret Info.tscn")


func _on_shop_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Shop.tscn")


func _on_gallary_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Achievement Gallary.tscn")
