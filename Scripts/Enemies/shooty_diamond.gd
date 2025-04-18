extends Enemy

class_name ShootyDiamond

var projectile = preload("res://Projectile Scenes/diamond.tscn")


@export var attackRange : float = 400
@export var projectileSpeed : float = 400

var turretsInRange = []

func _ready():
	enemyName = "Shooty Diamond"
	health = 75
	damage = 20
	attackTime = 5
	speed = 25
	attackTimer = $AttackTimer
	attackTimer.wait_time = attackTime
	attackTimer.start()

	hit.connect(EntityManager.takeDamage)

	$Area2D2/CollisionShape2D.shape.radius = attackRange


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Turret Projectile"):
		hit.emit(body.damage,body.shooter,self,body)

func _on_attack_timer_timeout() -> void:
	for x in turretsInRange:
		if not is_instance_valid(x):
			turretsInRange.erase(x)
	if turretsInRange.size() > 0:
		var turret = turretsInRange.pick_random()
		if is_instance_valid(turret):
			var proj = projectile.instantiate()
			proj.position = position

			proj.linear_velocity = (turret.global_position - global_position).normalized() * projectileSpeed

			var dif = self.global_position.angle_to_point(turret.global_position)

			proj.rotation = proj.rotation + dif
			proj.damage = damage
			proj.shooter = self
			get_parent().add_child(proj)

		else:
			turretsInRange.erase(turret)
	$AttackTimer.start()


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if is_instance_valid(body) and body.is_in_group("Turret"):
		turretsInRange.append(body)


func _on_area_2d_2_body_exited(body: Node2D) -> void:
	if is_instance_valid(body) and body.is_in_group("Turret") and turretsInRange.has(body):
		turretsInRange.erase(body)
