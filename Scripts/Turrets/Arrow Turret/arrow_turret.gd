extends Turret

class_name ArrowTurret

func _ready() -> void:

	projectile = preload("res://Projectile Scenes/arrow.tscn")

	rarity = Rarity.COMMON
	type = Type.Midieval
	turretID = TurretID.ARROW_TURRET

	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	baseHealth = TurretManager.getTurretStat(turretID,"health")
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseProjectileSpeed = TurretManager.getTurretStat(turretID,"projectileSpeed")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	baseReloadTime = TurretManager.getTurretStat(turretID,"reloadTime")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")

	upgradeTier = 0
	level = XpManager.getCurrentLevel(turretID)

	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	bottomSprite = $TurretBottom
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	selectAreaCollisionShape = $SelectArea/CollisionShape2D
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	maxHealth = baseHealth
	health = maxHealth

	hideRange()

	applyUpgrade()

	isPlaced = true

func attack():
	if shotReady and enemiesInRange.size() > 0 and isPlaced:

		var enemy = filterEnemy()

		shotReady = false
		if is_instance_valid(enemy) and isPlaced:

			var proj = projectile.instantiate()
			
			applyProjectileModifiers(proj)
			
			get_parent().add_child(proj)
			proj.position = position

			if level == 1:
				proj.speed = projectileSpeed
				proj.velocity = proj.global_position.direction_to(enemy.global_position) * projectileSpeed
			if level >= 2:
				proj.target = enemy
				proj.homingStrength = 4.0
				proj.speed = projectileSpeed
				proj.velocity = proj.global_position.direction_to(enemy.global_position) * projectileSpeed
			if level >= 3:
				proj.pierce = 99



			var dif = self.global_position.angle_to_point(enemy.global_position)

			proj.rotation = proj.rotation + dif
			proj.damage = damage
			proj.shooter = self

			reloadTimer.start()
			reloadAnimation()

			#dif = topSprite.global_position.angle_to_point(enemy.global_position)
			topSprite.look_at(enemy.global_position)
			topSprite.rotate(PI/2)

func reloadAnimation():

	var frameTime = reloadTime / 4.0
	var tween = create_tween()
	tween.tween_callback(func(): topSprite.frame = 1).set_delay(frameTime * 0)
	tween.tween_callback(func(): topSprite.frame = 2).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 3).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 0).set_delay(frameTime)

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = (baseDamage + (baseDamage * scaleFactor * upgradeTier))
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	projectileSpeed = (baseProjectileSpeed + (baseProjectileSpeed * scaleFactor * upgradeTier))
	reloadTime = max(1,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	reloadTimer.wait_time = reloadTime
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	refreshUI(self)
