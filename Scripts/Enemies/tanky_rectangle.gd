extends Enemy

class_name TankyRectangle

func _ready():
	enemyID = EnemyID.TANKY_RECTANGLE
	enemyName = EnemyManager.get_enemy_name(enemyID)
	health = EnemyManager.get_health(enemyID)
	damage = EnemyManager.get_damage(enemyID)
	attackTime = EnemyManager.get_attack_time(enemyID)
	speed = EnemyManager.get_speed(enemyID)
	sprite = $Sprite2D
	type = Type.BASIC
	attackTimer = $AttackTimer
	attackTimer.wait_time = attackTime
	hurtParticle = $"Basic Square Hurt"
	hitBoxArea = $HitboxArea
	applyScaling()

func _on_attack_timer_timeout() -> void:
	attackReady = true
	for x in hitBoxArea.get_overlapping_areas():
		var entity = x.get_parent()
		if entity.is_in_group("Turret"):
			EntityManager.turretTakeDamage(damage,entity,null)
			attackReady = false
			attackTimer.start()
