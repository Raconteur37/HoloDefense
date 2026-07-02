extends Minion

@onready var projectile = load("res://Projectile Scenes/arrow.tscn")

var attackTimer : Timer
var idleTimer
var attackReady : bool = true
var attackingEnemy : bool = false
var moveBack : bool = true

var attackRange
var projectileSpeed
var rangeArea

var level = XpManager.getCurrentLevel(Turret.TurretID.ARROW_TURRET)

var enemiesInRange = []

func _ready():
	id = MinionID.ARCHER
	attackTimer = $AttackTimer
	idleTimer = $IdleTimer
	attackTimer.wait_time = attackTime
	sprite = $Sprite2D
	rangeArea = $RangeArea/CollisionShape2D
	rangeArea.shape.radius = attackRange
	var angle = randf_range(0, 2 * PI)
	var direction = (Vector2(cos(angle), sin(angle))).normalized()
	velocity = direction * speed
	await get_tree().create_timer(.2).timeout
	velocity = Vector2(0,0)

func updateAttackTime():
	attackTimer.wait_time = attackTime

func _process(delta: float) -> void:
	for z in turretOwner.get_node("RangeArea").get_overlapping_areas():
			if z.get_parent().is_in_group("Enemy"):
				enemiesInRange.append(z.get_parent())

	if attackReady and enemiesInRange.size() > 0:
		shoot()

	if idleTimer.is_stopped():
		idleTimer.start()
	move_and_slide()



func _on_attack_timer_timeout() -> void:
	attackReady = true


func _on_idle_timer_timeout() -> void:
	if not attackingEnemy:
		var rand = randi_range(0,2)
		if rand == 0:
			var angle = randf_range(0, 2 * PI)
			var direction = (Vector2(cos(angle), sin(angle))).normalized()
			velocity = direction * 100
			await get_tree().create_timer(.5).timeout
			velocity = Vector2(0,0)
		else:
			var direction = (turretOwner.global_position - global_position).normalized()
			velocity = direction * 100
			await get_tree().create_timer(.5).timeout
			velocity = Vector2(0,0)
		idleTimer.start()

func shoot():
	var enemy = EntityManager.getClosestEnemyFromSprite(self)

	attackReady = false
	if is_instance_valid(enemy):

		var proj = projectile.instantiate()
		applyProjectileModifiers(proj)
		get_parent().add_child(proj)
		proj.position = position


		if level == 1:
			proj.speed = projectileSpeed
			proj.velocity = proj.global_position.direction_to(enemy.global_position) * projectileSpeed
		if level >= 2:
			proj.target = enemy
			proj.homingStrength = 4.0
			proj.speed = projectileSpeed
			proj.velocity = proj.global_position.direction_to(enemy.global_position) * projectileSpeed
		if level >= 3:
			proj.pierce = 99

		var dif = self.global_position.angle_to_point(enemy.global_position)

		proj.rotation = proj.rotation + dif
		proj.damage = damage
		proj.shooter = turretOwner
		
		attackTimer.start()
		

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)


func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)
