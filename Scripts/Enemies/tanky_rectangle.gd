extends Enemy

class_name TankyRectangle

func _ready():
	enemyName = "Tanky Rectangle"
	health = 90
	damage = 5
	attackTime = 7
	speed = 20
	attackTimer = $AttackTimer
	attackTimer.wait_time = attackTime

	#hit.connect(EntityManager.takeDamage)

	#EntityManager.increaseEnemyStats(self)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Turret Projectile"):
		hit.emit(body.damage,body.shooter,self,body)
	if body.is_in_group("Turret"):
		if body.get("isPlaced") != null:
			if body.isPlaced:
				body.hit.emit(damage,body)
				attackReady = false
				attackTimer.start()

	if body.is_in_group("Minion"):
		body.hit.emit(damage,body)
		attackReady = false
		attackTimer.start()

func _on_attack_timer_timeout() -> void:
	attackReady = true
	for x in $Area2D.get_overlapping_areas():
		var entity = x.get_parent()
		if entity.is_in_group("Turret") and x.name.contains("SelectArea"):
			entity.hit.emit(damage,entity)
			attackReady = false
			attackTimer.start()
