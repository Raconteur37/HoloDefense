extends Control


func _input(event):
	if event.is_action_pressed("ui_cancel"): # Usually mapped to ESC
		toggle_pause()
	if event is InputEventKey:
		if event.keycode == KEY_F1 and event.pressed and visible:
			get_tree().quit()
		if event.keycode == KEY_F2 and event.pressed and visible:
			get_tree().paused = false
			GameManager.reset()
			get_tree().change_scene_to_file("res://Game Scenes/Loadout.tscn")
			#get_tree().reload_current_scene()

func toggle_pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state # Show/hide the menu
