extends Enemy

class_name Dummy

func _ready():
	enemyName = "Dummy"
	health = 99999999
	damage = 10
	attackTime = 3
	attackTimer = $AttackTimer
	attackTimer.wait_time = attackTime

	hit.connect(EntityManager.takeDamage)

	EntityManager.increaseEnemyStats(self)
