extends RigidBody2D

var shooter
var damage

var turnSpeed : float = 100
var target
var speed = 600

var velocity: Vector2 = Vector2.ZERO
var tracking_force: float = 2000  # Tune this value
var max_speed: float = 400.0       # Optional speed limit

func _physics_process(delta):
	if not target or not is_instance_valid(target):
		return

	var direction_to_target = (target.global_position - global_position).normalized()

	# Apply acceleration toward target
	var acceleration = direction_to_target * tracking_force
	velocity += acceleration * delta

	# Optional: clamp max speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	# Move the projectile
	position += velocity * delta

func _on_despawn_timer_timeout() -> void:
	queue_free()
