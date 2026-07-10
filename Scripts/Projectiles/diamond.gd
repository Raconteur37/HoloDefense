extends Area2D

var shooter
var damage
var velocity: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	# Manually move the projectile every frame
	global_position += velocity * delta

func _on_despawn_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Turret"):
		EntityManager.turretTakeDamage(damage, body, self, shooter)
		queue_free() # Optional: Destroy the projectile after it hits
