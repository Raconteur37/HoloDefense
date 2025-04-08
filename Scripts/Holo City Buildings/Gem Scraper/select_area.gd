extends Area2D

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("pressed")
			var uiScene = load("res://Globals/Scene/HoloGeneratorUIScene.tscn")
			var loadedScene = uiScene.instantiate()
			get_tree().current_scene.find_child("CanvasLayer").add_child(loadedScene)
