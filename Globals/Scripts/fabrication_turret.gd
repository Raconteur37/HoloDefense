extends Control

var turretNumber
var constructed = false
var turretName

var turretConveyorItem

var animationPlayer

var timer
var constructionTime

func _ready() -> void:
	timer = $ConstructionTimer
	timer.wait_time = constructionTime
	turretConveyorItem = $"Turret Conveyor Item"
	animationPlayer = $AnimationPlayer
	animationPlayer.play("Play Conveyor Animation")

func startConstruction():
	timer.start()
	
func getName():
	return turretName

func _on_construction_timer_timeout() -> void:
	constructed = true
	get_parent().addToStorageDict(turretName)
	get_parent().removeItemFromBuildQueue(self)
	get_parent().buildingItems -= 1
	queue_free()
