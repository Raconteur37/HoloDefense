extends Node2D

var activeParticleEffect

var effectName = "Fire"
var damage = 0 # Default 0
var turretApplier = null # Need this to be null in case I forgot to apply the turret
var enemy = null # same for this

var tickTimer
var totalTimeTimer

var tickTime = 1

func _ready() -> void:
	tickTimer = $Tick
	tickTimer.wait_time = tickTime
	var fireParticle = load("res://Particle Scenes/Effects/fire.tscn")
	activeParticleEffect = fireParticle.instantiate()
	activeParticleEffect.global_position = enemy.global_position
	get_tree().root.current_scene.add_child(activeParticleEffect)


func _process(delta: float) -> void:
	if not is_instance_valid(enemy): # Somehow the enemy is removed without death
		activeParticleEffect.queue_free()
		queue_free()
	else:
		activeParticleEffect.global_position = enemy.global_position

func applyData(turret,victim,fireDamage,time):
	turretApplier = turret
	enemy = victim
	damage = fireDamage
	$"Total Time".wait_time = time
	$"Total Time".start()
	# Instantiate the particle effect

func restartTime(time):
	$"Total Time".start($"Total Time".wait_time)

func getName():
	return effectName

func _on_tick_timeout() -> void:
	enemy.hit.emit(damage,turretApplier,enemy)
	tickTimer.start()

func _on_total_time_timeout() -> void:
	activeParticleEffect.queue_free()
	EffectManager.removeEffect(enemy,self)
	queue_free()
