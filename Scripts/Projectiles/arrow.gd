extends Projectile

var turnSpeed : float = 100

var velocity: Vector2 = Vector2.ZERO
var tracking_force: float = 2000  # Tune this value
var max_speed: float = 400.0       # Optional speed limit

func _ready() -> void:
	super._ready()  # runs parent _ready, sets contact monitor + connects signal

func _physics_process(delta):
	if not target or not is_instance_valid(target):
		return

	var direction = (target.global_position - global_position).normalized()
	
	var desired_velocity = direction * max_speed
	var steering = (desired_velocity - linear_velocity).normalized() * tracking_force * delta
	
	linear_velocity += steering

	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
		
	# 4. Point the projectile in the direction of travel
	rotation = linear_velocity.angle()

func _on_despawn_timer_timeout() -> void:
	queue_free()
