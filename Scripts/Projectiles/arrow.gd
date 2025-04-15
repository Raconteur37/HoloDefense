extends RigidBody2D

var shooter
var damage

var turnSpeed : float = 100
var target
var speed = 600

func _physics_process(delta):
	if not target or not is_instance_valid(target):
		return

	var to_target = (target.global_position - global_position).normalized()
	var forward = Vector2.UP.rotated(rotation)  

	var angle_diff = forward.angle_to(to_target)
	var angle_step = turnSpeed * delta
	angle_diff = clamp(angle_diff, -angle_step, angle_step)
	rotation += angle_diff

	apply_central_force(Vector2.UP.rotated(rotation) * speed) 

func _on_despawn_timer_timeout() -> void:
	queue_free()
