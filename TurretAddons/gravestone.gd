extends Node2D

var scanRange
var turretApplier

var enemiesInRange = []

@onready var timer = $Timer

@onready var line2d = $RangeArea/RangeIndicator
@onready var collisionShape = $RangeArea/CollisionShape2D

func build(turret,scanrange,duration):
	turretApplier = turret
	scanRange = scanrange
	timer.wait_time = duration
	$GravestoneExplode.emitting = true
	line2d = TurretManager.draw_range_circle(line2d,scanRange)
	collisionShape.shape.radius = scanRange
	line2d.default_color = Color(0.322, 0.397, 0.415, 0.55)
	timer.start()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Fadeout":
		queue_free()


func _on_timer_timeout() -> void:
	$AnimationPlayer.play("Fadeout")
	if turretApplier.level >= 3:
		for enemy : Enemy in enemiesInRange:
			if not enemy.effects.has(EffectClass.Effect.ZOMBIFY):
				EffectManager.applyZombifyEffect(enemy,turretApplier,turretApplier.turnTime)


func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)


func _on_range_area_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.erase(body)
