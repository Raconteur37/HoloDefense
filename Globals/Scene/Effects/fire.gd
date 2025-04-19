extends Node2D

var particleEffect

var effectName = "Fire"
var damage = 0 # Default 0
var turretApplier = null # Need this to be null in case I forgot to apply the turret
var enemy = null # same for this

var tickTimer

var tickTime = 1

func _ready() -> void:
	tickTimer = $Tick
	tickTimer.wait_time = tickTime
	particleEffect = $Fire
	particleEffect.global_position = enemy.global_position



func _process(delta: float) -> void:
	if not is_instance_valid(enemy): # Somehow the enemy is removed without death
		queue_free()
	else:
		particleEffect.global_position = enemy.global_position

func applyData(turret,victim,fireDamage,time):
	turretApplier = turret
	enemy = victim
	damage = fireDamage
	$"Total Time".wait_time = time
	victim.effects["Fire"] = self

func restartTime(time):
	$"Total Time".start($"Total Time".wait_time)

func getName():
	return effectName

func _on_tick_timeout() -> void:
	enemy.hit.emit(damage,turretApplier,enemy,self)
	tickTimer.start()

func _on_total_time_timeout() -> void:
	EffectManager.removeEffect(enemy,self)
	queue_free()
