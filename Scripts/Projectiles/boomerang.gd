extends Projectile
class_name Boomerang

var returnOnHit: bool = false  # if true, returns after first hit

var _hasReturned: bool = false
var hitEnemies: Array = []  # track pierced enemies so we don't double hit

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func launch(origin: Vector2, target: Vector2) -> void:
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

	moveTween.tween_method(
		func(t: float):
			global_position = _quadratic_bezier(origin, mid, overshootTarget, t),
		0.0, 1.0, travelTime
	)

	moveTween.tween_interval(0.05)

	moveTween.tween_method(
		func(t: float):
			var shooterPos := shooter.global_position if is_instance_valid(shooter) else origin
			global_position = _quadratic_bezier(overshootTarget, returnMid, shooterPos, t)
			_hasReturned = true,
		0.0, 1.0, travelTime * 0.8
	)

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
