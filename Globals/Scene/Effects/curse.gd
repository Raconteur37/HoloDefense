extends Node2D

var particleEffect

var effectName = "Curse"
var turretApplier = null # Need this to be null in case I forgot to apply the turret
var enemy = null # same for this

var tickTimer

func _ready() -> void:
	particleEffect = $CurseParticle
	particleEffect.global_position = enemy.global_position

func _process(delta: float) -> void:
	if not is_instance_valid(enemy): # Somehow the enemy is removed without death
		queue_free()
	else:
		particleEffect.global_position = enemy.global_position

func applyData(turret,victim,time):
	turretApplier = turret
	enemy = victim
	enemy.curseDamageAmp = turret.curseDamageAmp
	$"Total Time".wait_time = time
	enemy.effects.append("Curse")
	$"Total Time".start()

func restartTime(time):
	$"Total Time".start($"Total Time".wait_time)

func getName():
	return effectName

func _on_total_time_timeout() -> void:
	print("got hgerer")
	EffectManager.removeEffect(enemy,self)
	queue_free()
