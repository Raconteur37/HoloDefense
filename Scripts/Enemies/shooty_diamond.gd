extends Enemy

class_name ShootyDiamond

var projectile = preload("res://Projectile Scenes/diamond.tscn")


func _ready():
	enemyID = EnemyID.SHOOTY_DIAMOND
	enemyName = EnemyManager.get_enemy_name(enemyID)
	health = EnemyManager.get_health(enemyID)
	maxHealth = health
	damage = EnemyManager.get_damage(enemyID)
	attackTime = EnemyManager.get_attack_time(enemyID)
	speed = EnemyManager.get_speed(enemyID)
	attackRange = EnemyManager.get_range(enemyID)
	projectileSpeed = EnemyManager.get_range(enemyID)
	ranged = true
	tier = EnemyManager.get_tier(enemyID)
	sprite = $Sprite2D
	type = Type.BASIC
	attackTimer = $AttackTimer
	hurtParticle = $"Basic Square Hurt"
	hitBoxArea = $HitboxArea
	attackTimer.wait_time = attackTime
	attackTimer.start()
	rollForElite()
	applyScaling()

	$Area2D/CollisionShape2D.shape.radius = attackRange


func _on_attack_timer_timeout() -> void:
	if isZombie:
		return
	for x in turretsInRange:
		if not is_instance_valid(x):
			turretsInRange.erase(x)
	if turretsInRange.size() > 0:
		var turret = turretsInRange.pick_random()
		if is_instance_valid(turret):
			var proj = projectile.instantiate()
			proj.position = position

			proj.velocity = (turret.global_position - global_position).normalized() * projectileSpeed
			
			var dif = self.global_position.angle_to_point(turret.global_position)

			proj.rotation = proj.rotation + dif
			proj.damage = damage
			proj.shooter = self
			get_parent().add_child(proj)

		else:
			turretsInRange.erase(turret)
	attackTimer.start()


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if is_instance_valid(body) and body.is_in_group("Turret"):
		turretsInRange.append(body)


func _on_area_2d_2_body_exited(body: Node2D) -> void:
	if is_instance_valid(body) and body.is_in_group("Turret") and turretsInRange.has(body):
		turretsInRange.erase(body)
