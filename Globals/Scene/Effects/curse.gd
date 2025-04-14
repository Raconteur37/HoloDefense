extends Node2D

var particleEffect

var effectName = "Curse"
var turretApplier = null # Need this to be null in case I forgot to apply the turret
var enemy = null # same for this

var tickTimer
var totalTime

func _ready() -> void:
	totalTime = $"Total Time"
	particleEffect = $PoisonParticle
	particleEffect.global_position = enemy.global_position

func _process(delta: float) -> void:
	if not is_instance_valid(enemy): # Somehow the enemy is removed without death
		queue_free()
	else:
		particleEffect.global_position = enemy.global_position

func applyData(turret,victim,effectDamage,time):
	turretApplier = turret
	enemy = victim
	totalTime.wait_time = time
	totalTime.start()

func restartTime(time):
	totalTime.start(totalTime.wait_time)

func getName():
	return effectName

func _on_tick_timeout() -> void:
	if enemy.health - damage > 0:
		enemy.hit.emit(damage,turretApplier,enemy,self)
	tickTimer.start()

func _on_total_time_timeout() -> void:
	EffectManager.removeEffect(enemy,self)
	queue_free()
