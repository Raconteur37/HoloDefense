extends Control


func _on_solo_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Loadout.tscn")


func _on_multiplayer_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Multiplayer Lobby.tscn")
