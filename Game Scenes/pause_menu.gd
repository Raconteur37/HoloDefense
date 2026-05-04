extends Control


func _input(event):
	if event.is_action_pressed("ui_cancel"): # Usually mapped to ESC
		toggle_pause()

func toggle_pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state # Show/hide the menu
