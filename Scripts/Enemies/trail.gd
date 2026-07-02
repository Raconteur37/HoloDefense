extends Node2D
class_name MotionTrail

@export var target: Sprite2D
@export var trail_enabled: bool = true
@export var trail_color: Color = Color(0.3, 0.9, 1.0, 0.6)
@export var min_speed_to_trail: float = 5.0
@export var particle_lifetime: float = 0.3
@export var particle_amount: int = 24
@export var spread_degrees: float = 10.0
@export var initial_velocity_min: float = 10.0
@export var initial_velocity_max: float = 25.0
@export var scale_min: float = 0.25
@export var scale_max: float = 0.4

var particles: CPUParticles2D
var _last_position: Vector2

func _ready() -> void:
	if target == null:
		push_warning("MotionTrail on '%s' has no target assigned." % get_parent().name)
	_last_position = global_position
	_setup_particles()

func _setup_particles() -> void:
	particles = CPUParticles2D.new()
	add_child(particles)

	particles.emitting = false
	particles.amount = particle_amount
	particles.lifetime = particle_lifetime
	particles.one_shot = false
	particles.explosiveness = 0.0
	particles.local_coords = false   # emit in world space so particles stay put as target moves away
	particles.texture = target.texture if target else null
	particles.spread = spread_degrees
	particles.initial_velocity_min = initial_velocity_min
	particles.initial_velocity_max = initial_velocity_max
	particles.scale_amount_min = scale_min
	particles.scale_amount_max = scale_max
	particles.gravity = Vector2.ZERO
	particles.damping_min = 20.0     # particles slow down as they age, keeps trail tight/narrow
	particles.damping_max = 30.0
	particles.z_index = (target.z_index - 1) if target else -1

	# fade color ramp: full trail_color at birth -> transparent at death
	var gradient := Gradient.new()
	gradient.set_color(0, Color(trail_color.r, trail_color.g, trail_color.b, trail_color.a))
	gradient.set_color(1, Color(trail_color.r, trail_color.g, trail_color.b, 0.0))
	var gradient_tex := GradientTexture1D.new()
	gradient_tex.gradient = gradient
	particles.color_ramp = gradient_tex

func _process(delta: float) -> void:
	if not trail_enabled or target == null or particles == null:
		return

	particles.global_position = target.global_position

	var move_delta := target.global_position - _last_position
	var speed_estimate := move_delta.length() / delta

	if speed_estimate > min_speed_to_trail:
		particles.emitting = true
		# aim emission opposite the movement direction so particles trail behind
		particles.direction = -move_delta.normalized()
	else:
		particles.emitting = false

	_last_position = target.global_position
