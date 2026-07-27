extends Control

@onready var soloFrame = $"Solo Frame"

@onready var portal = $PortalFX
@onready var difficultySlider = $"Solo Frame/Difficulty Slider"
@onready var turretTitle = $TurretTitle
@onready var turretDescriptionOne = $TypeLabel
@onready var difLabel = $DifficultyLabel
@onready var screenFilter = $ScreenFilter
@onready var launchLabel = $LaunchLabel
@onready var launchButton = $"Solo Frame/BeginButton"

@onready var animationPlayer = $AnimationPlayer

func _ready() -> void:
	portal.hide()
	SoundManager.stopMusic()
	Engine.time_scale = 1
	if not SettingsManager.is_tutorial_done():
		get_tree().change_scene_to_file("res://Game Scenes/Tutorial Scene.tscn")
	difficultySlider.value = GameManager.difficultySave


func _on_solo_frame_visibility_changed() -> void:
	if soloFrame != null:
		if soloFrame.visible:
			animationPlayer.play("PortalAppear")
			turretTitle.show()
			turretDescriptionOne.show()
			portal.show()
			difLabel.show()
			if launchButton.visible:
				launchLabel.show()
		else:
			difLabel.hide()
			turretTitle.hide()
			turretDescriptionOne.hide()
			portal.hide()
			launchLabel.hide()


func _on_difficulty_slider_value_changed(value: float) -> void:
	if value >= 1 and value <= 4:
		difLabel.text = "[pulse color=green height=0.5 freq=0.3][font_size=20]Difficulty: " + str(int(value)) + "[/font_size][/pulse]"
	if value >= 5 and value <= 8:
		difLabel.text = "[pulse color=yellow height=0.5 freq=0.3][font_size=20]Difficulty: " + str(int(value)) + "[/font_size][/pulse]"
	if value >= 9:
		difLabel.text = "[pulse color=red height=0.5 freq=0.3][font_size=20]Difficulty: " + str(int(value)) + "[/font_size][/pulse]"
	WaveManager.currentDifficulty = int(value)
	portal.material.set_shader_parameter("intensity", value)
	screenFilter.material.set_shader_parameter("speed", 0.1 * value)
	screenFilter.material.set_shader_parameter("orb_count", 25 * value)
	SoundManager.playDifficultySound(int(value))


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Launch":
		get_tree().change_scene_to_file("res://Game Scenes/Game.tscn")
		GameManager.difficultySave = WaveManager.currentDifficulty
