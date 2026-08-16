extends Enemy
class_name DrillingCone

var target = null
var chargeSpeedMultiplier: float = 2.0 

func _ready():
	enemyID = EnemyID.DRILLING_CONE
	enemyName = EnemyManager.get_enemy_name(enemyID)
	health = EnemyManager.get_health(enemyID)
	maxHealth = health
	damage = EnemyManager.get_damage(enemyID)
	attackTime = EnemyManager.get_attack_time(enemyID)
	speed = EnemyManager.get_speed(enemyID)
	tier = EnemyManager.get_tier(enemyID)
	attackRange = EnemyManager.get_range(enemyID)
	
	sprite = $Sprite2D
	type = Type.BASIC
	attackTimer = $AttackTimer
	attackTimer.wait_time = attackTime
	hurtParticle = $"Basic Square Hurt"
	hitBoxArea = $HitboxArea
	rollForElite()
	applyScaling()
	
	$Area2D/CollisionShape2D.shape.radius = attackRange

func _physics_process(delta: float) -> void:
	if is_sent_enemy and not multiplayer.is_server():
		return
	
	if knockbackVelocity != Vector2.ZERO:
		knockbackVelocity = knockbackVelocity.move_toward(Vector2.ZERO, knockbackDecay * delta)
	
	if stunned and eliteType != EliteType.UNSTOPPABLE:
		if knockbackVelocity != Vector2.ZERO:
			velocity = knockbackVelocity
			move_and_slide() 
		return

	# --- Target Management ---
	# Only hunt turrets if it is NOT a zombie
	if not isZombie:
		turretsInRange = turretsInRange.filter(func(t): return is_instance_valid(t))
		
		if target == null or not is_instance_valid(target):
			if turretsInRange.size() > 0:
				target = turretsInRange[0] 
			else:
				target = null 
	else:
		# If it becomes a zombie, clear the target immediately
		target = null

	var direction = Vector2.ZERO
	var current_speed = speed 

	# --- Pathing Logic ---
	if target != null: 
		direction = (target.global_position - global_position).normalized()
		current_speed = speed * chargeSpeedMultiplier 
	else:
		updateDestination()
		if destination != Vector2.ZERO:
			direction = (destination - global_position).normalized()
			
	if direction != Vector2.ZERO:
		velocity = (direction * current_speed) + knockbackVelocity
		rotation = direction.angle() - (PI / 2.0) 
	else:
		velocity = knockbackVelocity

	move_and_slide()
	
	var is_drilling = false
	
	# --- Attack Logic ---
	# Only allow drilling if it is NOT a zombie
	if not isZombie:
		for x in hitBoxArea.get_overlapping_areas():
			var entity = x.get_parent()
			if entity.is_in_group("Turret"):
				is_drilling = true
				
				if attackReady:
					EntityManager.turretTakeDamage(damage, entity, null, self)
					attackReady = false
					attackTimer.start()
				
	if is_drilling:
		sprite.position.x = sin(Time.get_ticks_msec() * 0.05) * 3.0
	else:
		sprite.position.x = 0.0
	
	if isZombie and not initialTurn:
		initZombie()

func _on_attack_timer_timeout() -> void:
	attackReady = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	super(body)
	if is_instance_valid(body) and body.is_in_group("Turret"):
		if target == null:
			target = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	super(body)
	if is_instance_valid(body) and body.is_in_group("Turret"):
		if body == target:
			target = null
