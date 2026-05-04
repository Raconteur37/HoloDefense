extends Node2D

var cityCanvas
var defenseCanvas

var transition

func _ready() -> void:
	transition = $transition
	cityCanvas = $CityCanvas
	defenseCanvas = $TowerDefenseCanvas
	WaveManager.beginNextSystem()


func _input(event: InputEvent):
	if event.is_action_pressed("swap_scene"):
		if cityCanvas.visible:
			cityCanvas.hide()
			transition.play()
			await get_tree().create_timer(.9).timeout
			defenseCanvas.show()
		else:
			defenseCanvas.hide()
			transition.play()
			await get_tree().create_timer(.9).timeout
			cityCanvas.show()
