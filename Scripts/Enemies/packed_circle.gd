extends Enemy

class_name PackedCircle

func _ready():
	enemyID = EnemyID.PACKED_CIRCLE
	enemyName = EnemyManager.get_enemy_name(enemyID)
	health = EnemyManager.get_health(enemyID)
	maxHealth = health
	damage = EnemyManager.get_damage(enemyID)
	speed = EnemyManager.get_speed(enemyID)
	tier = EnemyManager.get_tier(enemyID)
	explosionDamage = damage
	explosionRadius = EnemyManager.get_explosion_radius(enemyID)
	minisSpawned = EnemyManager.get_minis_spawned(enemyID)
	ranged = false
	sprite = $Sprite2D
	type = Type.BASIC
	hurtParticle = $"Basic Square Hurt"
	hitBoxArea = $HitboxArea
	rollForElite()
	applyScaling()

var is_dead: bool = false 

func deathEvent():
	if is_dead:
		return
	is_dead = true
	
	ExplosionManager.spawnEnemyExplosion(self, explosionRadius, explosionDamage)
	self.hide()
	
	for x in range(minisSpawned):
		spawnMinis()
		
	WaveManager.removeActiveEnemy(self)

	await get_tree().create_timer(1).timeout
	queue_free()

func spawnMinis():
	var tempEnemy = load("res://Enemy Scenes/Mini Packed Circle.tscn").instantiate()
	
	# FIX: Add to the world (parent node), NOT to this specific dying enemy
	var holder = get_tree().current_scene.find_child("EnemyNodeHolder")
	holder.add_child(tempEnemy) 
	
	WaveManager.registerActiveEnemy(tempEnemy)
	tempEnemy.global_position = self.global_position

	# Launch outward
	var angle = randf_range(0, 2 * PI)
	var direction = Vector2(cos(angle), sin(angle)).normalized()
	tempEnemy.set_physics_process(false)

	var tween = tempEnemy.create_tween()
	tween.tween_property(
		tempEnemy,
		"global_position",
		self.global_position + direction * 120.0,
		0.6
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(func():
		tempEnemy.set_physics_process(true)
	)


func _on_hitbox_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Turret"):
		deathEvent()
