extends Node2D

var turretNumber
var constructed = false
var turretName

var timer
var constructionTime

func _ready() -> void:
	timer = $ConstructionTimer
	timer.wait_time = constructionTime

func startConstruction():
	timer.start()
	
func getName():
	return turretName

func _on_construction_timer_timeout() -> void:
	constructed = true
	get_parent().addToStorageDict(turretName)
	get_parent().removeItemFromBuildQueue(self)
	queue_free()
