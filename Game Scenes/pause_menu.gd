extends CanvasLayer

@onready var background = $Background

@onready var generalButtons = $Background/GeneralButtons
@onready var settingsButtons = $"Background/Settings Buttons"
@onready var audioSettings = $"Background/Audio Settings"

@onready var giveup = $Background/GeneralButtons/VBoxContainer/GiveUp

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_cancel") and not GameManager.VSmode: # Usually mapped to ESC
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
	if visible:
		generalButtons.show()
		settingsButtons.hide()
		audioSettings.hide()
		if get_tree().current_scene.find_child("TowerDefenseCanvas") != null:
			if get_tree().current_scene.find_child("TowerDefenseCanvas").find_child("HoloCityDisplay").runActive:
				giveup.show()
		else:
			giveup.hide()

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


func _on_give_up_pressed() -> void:
	get_tree().paused = false
	get_tree().current_scene.find_child("TowerDefenseCanvas").find_child("HoloCityDisplay").runActive = false
	StatManager.elapsedTime = get_tree().current_scene.find_child("TowerDefenseCanvas").find_child("HoloCityDisplay").runTime
	get_tree().change_scene_to_file("res://Game Scenes/RewardScene.tscn")


func _on_back_settings_pressed() -> void:
	settingsButtons.hide()
	generalButtons.show()


func _on_back_audio_settings_pressed() -> void:
	$"Background/Audio Settings/VBoxContainer/Label/musicVolume".value = SoundManager.musicVolume
	$"Background/Audio Settings/VBoxContainer/Label2/uiVolume".value = SoundManager.uiVolume
	audioSettings.hide()
	settingsButtons.show()


func _on_audio_pressed() -> void:
	audioSettings.show()
	settingsButtons.hide()


func _on_settings_pressed() -> void:
	settingsButtons.show()
	generalButtons.hide()


func _on_ui_volume_value_changed(value: float) -> void:
	SoundManager.setUIVolume(value)
