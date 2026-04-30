extends Enemy

class_name BasicSquare

func _ready():
	enemyName = "Basic Square"
	health = 20
	damage = 10
	attackTime = 3
	speed = 50
	attackTimer = $AttackTimer
	attackTimer.wait_time = attackTime
	enemyID = EnemyID.BASIC_SQUARE
	hurtParticle = $"Basic Square Hurt"
	hitBoxArea = $HitboxArea


func _on_attack_timer_timeout() -> void:
	attackReady = true
	for x in hitBoxArea.get_overlapping_areas():
		var entity = x.get_parent()
		if entity.is_in_group("Turret"):
			EntityManager.turretTakeDamage(damage,entity)
			attackReady = false
			attackTimer.start()
