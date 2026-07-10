extends Node2D

var cityCanvas
var defenseCanvas
var waveData
var transition

# 1. Create a flag to track if the player is allowed to do things
var can_interact: bool = false 

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	transition = $transition
	cityCanvas = $CityCanvas
	defenseCanvas = $TowerDefenseCanvas
	waveData = $WaveData
	
	# Disable inputs while the intro plays
	can_interact = false 
	

	if not DeveloperMode.inDevMode:
		animationPlayer.play("RunIntro")
		SoundManager.playBeginRunSound()
	else:
		$AnimationPlayer.queue_free()
		can_interact = true 
		WaveManager.beginNextSystem()
	
	if DeveloperMode.inDevMode:
		$CanvasLayer.show()
	
func _input(event: InputEvent):
	# 2. Block all inputs if the animation is still playing
	if not can_interact:
		return
		
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
		# 3. Enable inputs now that the animation is done!
		can_interact = true 
		
		WaveManager.beginNextSystem()
		$AnimationPlayer/CanvasLayer.hide()
