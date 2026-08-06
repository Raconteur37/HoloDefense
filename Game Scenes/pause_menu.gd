extends Control

@onready var background = $Background

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_cancel"): # Usually mapped to ESC
		toggle_pause()
	if event is InputEventKey:
		if event.keycode == KEY_F1 and event.pressed and visible:
			get_tree().quit()
		if event.keycode == KEY_F2 and event.pressed and visible:
			get_tree().paused = false
			GameManager.reset()
			get_tree().change_scene_to_file("res://Game Scenes/Main Menu.tscn")
			#get_tree().reload_current_scene()

func toggle_pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state 


func _on_button_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameManager.reset()
	get_tree().change_scene_to_file("res://Game Scenes/Main Menu.tscn")
	#get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()



func _on_music_volume_value_changed(value: float) -> void:
	SoundManager.setMusicVolume(value)


func _on_music_toggle_toggled(toggled_on: bool) -> void:
		SoundManager.musicOn = toggled_on
		if not SoundManager.musicOn:
			SoundManager.stopMusic()


func _on_give_up_pressed() -> void:
	get_tree().paused = false
	get_tree().current_scene.find_child("TowerDefenseCanvas").find_child("HoloCityDisplay").runActive = false
	StatManager.elapsedTime = get_tree().current_scene.find_child("TowerDefenseCanvas").find_child("HoloCityDisplay").runTime
	get_tree().change_scene_to_file("res://Game Scenes/RewardScene.tscn")
