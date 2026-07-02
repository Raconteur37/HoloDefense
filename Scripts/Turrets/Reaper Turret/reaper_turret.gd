extends Turret

class_name ReaperTurret

@export var baseExecutionChance : float
@export var coneAngle : float = 70.0 # total width of the swing cone, in degrees - tweak in the Inspector

var particle

var executionChance

func _ready() -> void:
	projectile = preload("res://Projectile Scenes/sythe.tscn")
	rarity = Rarity.SUPER_RARE
	type = Type.Dark
	turretID = TurretID.REAPER_TURRET
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseHealth = maxHealth
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseProjectileSpeed = TurretManager.getTurretStat(turretID,"projectileSpeed")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	baseReloadTime = TurretManager.getTurretStat(turretID,"reloadTime")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	baseExecutionChance = TurretManager.getTurretStat(turretID,"executionChance")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	particle = $CPUParticles2D
	upgradeTier = 0
	level = 1
	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $ReaperTurretTop
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	rangeArea = $RangeArea
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth
	executionChance = baseExecutionChance
	isPlaced = true
	applyUpgrade()

func attack():
	if shotReady and enemiesInRange.size() > 0 and isPlaced:
		var enemy = EntityManager.getClosestEnemyFromSprite(self)
		shotReady = false
		
		if is_instance_valid(enemy) and isPlaced:
			
			topSprite.look_at(enemy.global_position)
			topSprite.rotate(PI/2)
			
			var aim_direction = global_position.direction_to(enemy.global_position)
			
			var right_direction = aim_direction.rotated(PI/2) 
			
			var forward_push = aim_direction * (attackRange * 0.35) 
			var side_push = right_direction * 13 # Tweak this 25.0 to push it further right!
			
			particle.global_position = global_position + forward_push + side_push
			
			particle.look_at(enemy.global_position)
			
			particle.rotate(PI/2)
			particle.emitting = true
			var coneArea = Area2D.new()
			coneArea.collision_mask = 0
			coneArea.collision_layer = 0
			coneArea.set_collision_mask_value(3, true)

			var polyShape = CollisionPolygon2D.new()
			var points = PackedVector2Array()
			
			points.append(Vector2.ZERO)
			
			
			var numPoints = 10
			var startAngle = -deg_to_rad(coneAngle / 2.0)
			var endAngle = deg_to_rad(coneAngle / 2.0)
			
			for i in range(numPoints + 1):
				var t = float(i) / numPoints
				var currentAngle = lerp(startAngle, endAngle, t)
				points.append(Vector2(cos(currentAngle), sin(currentAngle)) * attackRange)
				
			polyShape.polygon = points
			coneArea.add_child(polyShape)

			rangeArea.add_child(coneArea)
			coneArea.global_position = global_position
			coneArea.look_at(enemy.global_position)

			await get_tree().create_timer(.1).timeout

			if is_instance_valid(coneArea):
				for body in coneArea.get_overlapping_areas():
					var en = body.get_parent()
					if en.is_in_group("Enemy"):
						EntityManager.enemyTakeDamage(DamagePacket.new(damage, DamagePacket.Type.TURRET, self, [], {}), en)
						
						# Apply Execution Chance
						if randf_range(0.0, 100.0) <= executionChance:
							ParticleManager.playExecutionParticle(enemy)
							EntityManager.killEnemy(self, en)
							StatManager.addStat(turretID,"enemies_executed",1)

				await get_tree().create_timer(0.5).timeout
				coneArea.queue_free()

			reloadTimer.start()
			reloadAnimation()

func reloadAnimation():
	topSprite.frame = 1
	await get_tree().create_timer((reloadTime)).timeout
	topSprite.frame = 0

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true

func _on_select_area_mouse_entered() -> void:
	showUI(self)

func _on_select_area_mouse_exited() -> void:
	hideUI()

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = (baseDamage + (baseDamage * scaleFactor * upgradeTier))
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	rangeCollisionShape.shape.radius = attackRange
	projectileSpeed = (baseProjectileSpeed + (baseProjectileSpeed * scaleFactor * upgradeTier))
	reloadTime = max(1,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	reloadTimer.wait_time = reloadTime
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	executionChance = (baseExecutionChance + (baseExecutionChance * scaleFactor * upgradeTier))
	refreshUI(self)
