extends Control

var constructed = false
var turretID

var index

var animationPlayer

var turretTexture

var timer
var constructionTime

func _ready() -> void:
	timer = $ConstructionTimer
	animationPlayer = $AnimationPlayer
	turretTexture = $TurretTexture
	turretTexture.material = turretTexture.material.duplicate()
	#startConstruction(Turret.TurretID.RAILGUN_TURRET,5)

func startConstruction(turret,constructionTime,index):
	self.index = index
	turretID = turret
	turretTexture.texture = TurretManager.getTurretTexture(turretID)
	

	var library = animationPlayer.get_animation_library("")
	animationPlayer.remove_animation_library("")
	animationPlayer.add_animation_library("", library.duplicate(true))
	
	
	
	var waitTime = 1.0/constructionTime 
	timer.wait_time = constructionTime
	timer.start()
	animationPlayer.speed_scale = waitTime
	animationPlayer.play("Fabricate")

func _on_construction_timer_timeout() -> void:
	constructed = true
	await get_tree().create_timer(0.5).timeout
	# this isnt the best but it works for now
	get_tree().current_scene.find_child("Fabricator").finishConstruction(index,turretID)
	timer.queue_free()
	queue_free()
