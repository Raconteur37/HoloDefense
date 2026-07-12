extends Enemy

class_name SpeedyTriangle

func _ready():
	enemyID = EnemyID.SPEEDY_TRIANGLE
	enemyName = EnemyManager.get_enemy_name(enemyID)
	health = EnemyManager.get_health(enemyID)
	maxHealth = health
	damage = EnemyManager.get_damage(enemyID)
	attackTime = EnemyManager.get_attack_time(enemyID)
	speed = EnemyManager.get_speed(enemyID)
	tier = EnemyManager.get_tier(enemyID)
	type = Type.BASIC
	sprite = $Sprite2D
	attackTimer = $AttackTimer
	attackTimer.wait_time = attackTime
	hurtParticle = $"Basic Square Hurt"
	hitBoxArea = $HitboxArea
	rollForElite()
	applyScaling()
	
	var direction = destination - global_position
	
	var target_angle = direction.angle() + (PI / 2.0)
	
	# 3. Apply the rotation
	global_rotation = target_angle

func _on_attack_timer_timeout() -> void:
	attackReady = true
	for x in hitBoxArea.get_overlapping_areas():
		var entity = x.get_parent()
		if entity.is_in_group("Turret"):
			EntityManager.turretTakeDamage(damage,entity,null,self)
			attackReady = false
			attackTimer.start()
