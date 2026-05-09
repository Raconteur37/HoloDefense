extends RigidBody2D

var shooter
var damage

func _on_despawn_timer_timeout() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Turret"):
		EntityManager.turretTakeDamage(damage,body,self)
