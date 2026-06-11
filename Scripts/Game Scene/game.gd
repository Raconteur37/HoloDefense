extends Node2D

var cityCanvas
var defenseCanvas
var waveData
var transition

func _ready() -> void:
	transition = $transition
	cityCanvas = $CityCanvas
	defenseCanvas = $TowerDefenseCanvas
	waveData = $WaveData
	WaveManager.beginNextSystem()
	
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
