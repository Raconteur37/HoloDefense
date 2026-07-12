extends Enemy

class_name MiniPackedCircle

var is_dead = false

func _ready():
	enemyID = EnemyID.MINI_PACKED_CIRCLE
	enemyName = EnemyManager.get_enemy_name(enemyID)
	health = EnemyManager.get_health(enemyID)
	maxHealth = health
	damage = EnemyManager.get_damage(enemyID)
	attackTime = EnemyManager.get_attack_time(enemyID)
	speed = EnemyManager.get_speed(enemyID)
	tier = EnemyManager.get_tier(enemyID)
	explosionDamage = damage
	explosionRadius = EnemyManager.get_explosion_radius(enemyID)
	ranged = false
	sprite = $Sprite2D
	type = Type.BASIC
	hurtParticle = $"Basic Square Hurt"
	hitBoxArea = $HitboxArea
	applyScaling()


func deathEvent():
	if is_dead:
		return
	is_dead = true
	
	ExplosionManager.spawnEnemyExplosion(self, explosionRadius, explosionDamage)
	self.hide()

	WaveManager.removeActiveEnemy(self)

	await get_tree().create_timer(1).timeout
	queue_free()


func _on_hitbox_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Turret"):
		deathEvent()
