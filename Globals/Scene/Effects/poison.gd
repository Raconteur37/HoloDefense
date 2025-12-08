extends Node2D

var particleEffect

var effectName = "Poison"
var damage = 0 # Default 0
var turretApplier = null # Need this to be null in case I forgot to apply the turret
var enemy = null # same for this

var tickTimer

var tickTime = .3

func _ready() -> void:
	tickTimer = $Tick
	tickTimer.wait_time = tickTime
	particleEffect = $PoisonParticle
	particleEffect.global_position = enemy.global_position

func _process(_delta: float) -> void:
	if not is_instance_valid(enemy): # Somehow the enemy is removed without death
		queue_free()
	else:
		particleEffect.global_position = enemy.global_position

func applyData(turret,victim,effectDamage,time):
	if is_instance_valid(victim):
		turretApplier = turret
		enemy = victim
		damage = effectDamage
		$"Total Time".wait_time = time
		victim.effects["Poison"] = self

func restartTime(_time):
	$"Total Time".start($"Total Time".wait_time)

func getName():
	return effectName

func _on_tick_timeout() -> void:
	if is_instance_valid(enemy):
		if enemy.health - damage > 0:
			enemy.hit.emit(damage,turretApplier,enemy,self)
		tickTimer.start()
	else:
		EffectManager.removeEffect(enemy,self)

func _on_total_time_timeout() -> void:
	EffectManager.removeEffect(enemy,effectName)
