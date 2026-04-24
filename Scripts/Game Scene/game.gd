extends Node2D


func _ready() -> void:

	PlacementManager.inGame = true


func _input(event: InputEvent):
	if event.is_action_pressed("swap_scene"):
		if $CityCanvas.visible:
			$CityCanvas.hide()
		else:
			$CityCanvas.show()
