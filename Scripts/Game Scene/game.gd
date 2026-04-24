extends Node2D

var cityCanvas
var defenseCanvas


func _ready() -> void:

	cityCanvas = $CityCanvas
	defenseCanvas = $TowerDefenseCanvas


func _input(event: InputEvent):
	if event.is_action_pressed("swap_scene"):
		if cityCanvas.visible:
			cityCanvas.hide()
			defenseCanvas.show()
		else:
			cityCanvas.show()
			defenseCanvas.hide()
