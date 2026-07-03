extends Node2D

@onready var timer = $Timer
@onready var area = $Area2D

var turretApplier : Turret

func setupWeb(turret,duration,pos):
	global_position = pos
	turretApplier = turret
	timer.wait_time = duration
	timer.start()

func _process(delta: float) -> void:
	for body in area.get_overlapping_areas():
		var enemy = body.get_parent()
		if enemy.is_in_group("Enemy"):
			EffectManager.applyStunEffect(enemy,turretApplier,0.5)
			if turretApplier.level >= 3 and turretApplier.turretID == Turret.TurretID.SPIDER_TURRET:
				EffectManager.applyPoisonEffect(enemy,turretApplier,turretApplier.poisonDamage,turretApplier.poisonDuration)
	await get_tree().create_timer(0.2).timeout

func _on_timer_timeout() -> void:
	queue_free()
