extends Projectile
class_name Boomerang

var returnOnHit: bool = false  # if true, returns after first hit

var _hasReturned: bool = false
var hitEnemies: Array = []  # track pierced enemies so we don't double hit
var is_clone: bool = false  # Prevents clones from cloning themselves infinitely

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func launch(origin: Vector2, target: Vector2) -> void:
	# --- LEVEL 3: MULTI-SHOT SPREAD ---
	# If this is the original boomerang and the turret is level 3+, spawn 2 clones
	if not is_clone and is_instance_valid(shooter) and "level" in shooter and shooter.level >= 3:
		var parent = get_parent()
		if parent and scene_file_path != "":
			var spread_angle = deg_to_rad(20) # 20 degrees of separation
			var base_dir = (target - origin).normalized()
			var dist = origin.distance_to(target)
			
			# Create a left (-1.0) and right (1.0) clone
			for angle_mod in [-1.0, 1.0]:
				var clone = load(scene_file_path).instantiate()
				clone.is_clone = true
				
				# Copy standard Projectile variables to the clone
				clone.shooter = shooter
				clone.damage = damage
				clone.speed = speed
				clone.pierce = pierce
				
				parent.add_child(clone)
				
				# Calculate the rotated target position and launch the clone
				var rotated_dir = base_dir.rotated(spread_angle * angle_mod)
				var clone_target = origin + (rotated_dir * dist)
				clone.launch(origin, clone_target)

	global_position = origin

	var direction := (target - origin).normalized()
	var distance := origin.distance_to(target)
	
	var extendedDistance := distance + 100
	var overshootTarget := origin + (direction * extendedDistance)

	var perp := Vector2(-direction.y, direction.x)
	
	var mid := origin + direction * (extendedDistance * 0.5) + perp * (extendedDistance * 0.4)
	var returnMid := origin + direction * (extendedDistance * 0.3) - perp * (extendedDistance * 0.3)

	var travelTime := extendedDistance / speed
	var spinSpeed := remap(speed, 200.0, 800.0, 0.6, 0.2)

	var spinTween = create_tween().set_loops()
	spinTween.tween_property(self, "rotation", rotation + TAU, spinSpeed)

	var moveTween = create_tween()

	# Check if the shooter is level 2 or higher
	var extraArc = false
	if is_instance_valid(shooter) and "level" in shooter and shooter.level >= 2:
		extraArc = true

	# --- ARC 1 (Outward) ---
	moveTween.tween_method(
		func(t: float):
			global_position = _quadratic_bezier(origin, mid, overshootTarget, t),
		0.0, 1.0, travelTime
	)

	moveTween.tween_interval(0.05)

	# --- ARC 1 (Return) ---
	moveTween.tween_method(
		func(t: float):
			var shooterPos := shooter.global_position if is_instance_valid(shooter) else origin
			global_position = _quadratic_bezier(overshootTarget, returnMid, shooterPos, t)
			
			# If there's no extra arc, this is the final return where we allow catching
			if not extraArc:
				_hasReturned = true,
		0.0, 1.0, travelTime * 0.8
	)

	# --- ARC 2 (Extra Arc for Level 2+) ---
	if extraArc:
		# Clear hit enemies so we can damage them again on the second pass
		moveTween.tween_callback(func(): hitEnemies.clear())
		
		# We repeat the exact same arc forwards
		moveTween.tween_method(
			func(t: float):
				var shooterPos := shooter.global_position if is_instance_valid(shooter) else origin
				var over2 := shooterPos + (direction * extendedDistance)
				var m2 := shooterPos + direction * (extendedDistance * 0.5) + perp * (extendedDistance * 0.4)
				
				global_position = _quadratic_bezier(shooterPos, m2, over2, t),
			0.0, 1.0, travelTime
		)
		
		moveTween.tween_interval(0.05)
		
		moveTween.tween_method(
			func(t: float):
				var shooterPos := shooter.global_position if is_instance_valid(shooter) else origin
				var over2 := shooterPos + (direction * extendedDistance)
				var ret_m2 := shooterPos + direction * (extendedDistance * 0.3) - perp * (extendedDistance * 0.3)
				
				global_position = _quadratic_bezier(over2, ret_m2, shooterPos, t)
				
				# This is now the final return
				_hasReturned = true,
			0.0, 1.0, travelTime * 0.8
		)

	# Ensure it gets cleaned up when the tweens finish
	moveTween.tween_callback(queue_free)


func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 := p0.lerp(p1, t)
	var q1 := p1.lerp(p2, t)
	return q0.lerp(q1, t)


func _on_body_entered(body: Node) -> void:
	if body == shooter:
		if _hasReturned:
			queue_free()
		return
	if not body is Enemy:
		return
	if hitEnemies.has(body):
		return

	hitEnemies.append(body)
	EntityManager.enemyTakeDamage(buildPacket(), body)
	if hitEnemies.size() >= pierce:
		queue_free()


func buildPacket() -> DamagePacket:
	return DamagePacket.new(damage, DamagePacket.Type.PROJECTILE, shooter, [], {})
