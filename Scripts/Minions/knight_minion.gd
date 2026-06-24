extends Minion

var particle = preload("res://Particle Scenes/Minion/knight_attack.tscn")

var attackTimer : Timer
var idleTimer
var attackReady : bool = true
var attackingEnemy : bool = false
var moveBack : bool = true
var enemy = null

var enemiesList = []

func _ready():
	id = MinionID.KNIGHT
	attackTimer = $AttackTimer
	idleTimer = $IdleTimer
	attackTimer.wait_time = attackTime
	sprite = $Sprite2D
	var angle = randf_range(0, 2 * PI)
	var direction = (Vector2(cos(angle), sin(angle))).normalized()
	velocity = direction * speed
	await get_tree().create_timer(.2).timeout
	velocity = Vector2(0,0)

func updateAttackTime():
	attackTimer.wait_time = attackTime

func getName():
	return minionName

func _physics_process(delta: float) -> void:
	if enemy == null:
		attackingEnemy = false
		for z in turretOwner.get_node("RangeArea").get_overlapping_areas():
			if z.get_parent().is_in_group("Enemy"):
				enemiesList.append(z.get_parent())
		if enemiesList.size() > 0:
			enemy = enemiesList.pick_random()
			attackingEnemy = true
			enemiesList.clear()

	if attackingEnemy and enemy != null:
		var direction = (enemy.global_position - global_position).normalized()
		# Set the velocity to move toward the center
		velocity = direction * speed

		# Move and Slide with the current velocity
		move_and_slide()

	if not attackingEnemy:
		if idleTimer.is_stopped():
			idleTimer.start()
		move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		if attackReady:
			if is_instance_valid(body):
				EntityManager.enemyTakeDamage(DamagePacket.new(damage, DamagePacket.Type.TURRET, turretOwner, [], {}), body)
				var part = particle.instantiate()
				part.emitting = true
				part.global_position = to_local(body.global_position)
				part.global_position.x += 1
				#part.global_position.y -= 2
				add_child(part)
				attackReady = false
				attackTimer.start()

func _on_attack_timer_timeout() -> void:
	attackReady = true
	if enemy != null:
		for x in $Area2D.get_overlapping_areas():
			if x.get_parent() == enemy:
				EntityManager.enemyTakeDamage(DamagePacket.new(damage, DamagePacket.Type.MINION, turretOwner, [], {}), enemy)
				var part = particle.instantiate()
				part.emitting = true
				part.global_position = to_local(x.global_position)
				part.global_position.x += 1
				#part.global_position.y -= 2
				add_child(part)
				attackReady = false
		attackTimer.start()


func _on_idle_timer_timeout() -> void:
	if not attackingEnemy:
		var rand = randi_range(0,1)
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
