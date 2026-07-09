extends Node2D

var cityCanvas
var defenseCanvas
var waveData
var transition

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	transition = $transition
	cityCanvas = $CityCanvas
	defenseCanvas = $TowerDefenseCanvas
	waveData = $WaveData
	#WaveManager.beginNextSystem()
	SoundManager.playBeginRunSound()
	animationPlayer.play("RunIntro")
	if DeveloperMode.inDevMode:
		$CanvasLayer.show()
	
func _input(event: InputEvent):
	if event.is_action_pressed("swap_scene"):
		if cityCanvas.visible:
			cityCanvas.hide()
			transition.play()
			waveData.hide()
			await get_tree().create_timer(.55).timeout
			defenseCanvas.show()
			waveData.show()
		else:
			defenseCanvas.hide()
			transition.play()
			waveData.hide()
			await get_tree().create_timer(.55).timeout
			cityCanvas.show()
			waveData.show()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "RunIntro":
		WaveManager.beginNextSystem()
		$AnimationPlayer/CanvasLayer.hide()
