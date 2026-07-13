extends Projectile
class_name MortarShell

var start_pos: Vector2
var target_pos: Vector2
var previous_pos: Vector2 # Added to track movement direction

var arc_height: float = 150.0  
var travel_time: float = 1.2   
var time_passed: float = 0.0

var is_airborne: bool = false

func _ready() -> void:
	pass

func fire(from: Vector2, to: Vector2) -> void:
	start_pos = from
	target_pos = to
	previous_pos = from # Initialize the previous position
	position = start_pos
	time_passed = 0.0
	is_airborne = true
	$CollisionShape2D.set_deferred("disabled", true)

func _process(delta: float) -> void:
	if not is_airborne:
		return
		
	time_passed += delta
	var t = clamp(time_passed / travel_time, 0.0, 1.0)
	
	# 1. Calculate new position
	var linear_pos = start_pos.lerp(target_pos, t)
	var height_offset = 4.0 * arc_height * t * (1.0 - t)
	var new_pos = Vector2(linear_pos.x, linear_pos.y - height_offset)
	
	# 2. Update rotation based on where we are moving
	var direction = new_pos - previous_pos
	if direction.length_squared() > 0: # Ensure we don't calculate angle on a zero-vector
		rotation = direction.angle()
	
	# 3. Apply position and save it for the next frame
	position = new_pos
	previous_pos = new_pos
	
	# 4. Check if we've landed
	if t >= 1.0:
		land()

func land() -> void:
	is_airborne = false
	position = target_pos
	if shooter.level >= 2:
		var firePool = load("res://TurretAddons/FirePool.tscn").instantiate()
		
		shooter.add_child(firePool) 
		
		firePool.global_position = self.global_position 
		
		firePool.buildPool(shooter, shooter.poolIgniteTime, shooter.poolIgniteDamage, shooter.poolTime, shooter.poolRadius)
	explode()
	

func explode() -> void:
	var fxData = {
	"explosionRadius": shooter.explosionRadius,
	"explosionDamage": shooter.explosionDamage
	}
	ExplosionManager.summonExplosion(shooter,position,fxData)
	
	queue_free()
