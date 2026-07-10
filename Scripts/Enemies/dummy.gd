extends Turret

class_name Dummy

@onready var knightAttack = $KnightAttack

func _ready():
	health = 99999999
	damage = 10
	#EntityManager.increaseEnemyStats(self)


func _on_attack_timer_timeout() -> void:
	for enemy in enemiesInRange:
		if is_instance_valid(enemy):
			EntityManager.enemyTakeDamage(DamagePacket.new(damage, DamagePacket.Type.DUMMY, self, [], {}),enemy)
			knightAttack.emitting = true
			knightAttack.global_position = enemy.global_position
		else:
			enemiesInRange.erase(enemy)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)
