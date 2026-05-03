extends Turret

class_name MiniSentryTurret

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	projectile = preload("res://Projectile Scenes/sentry bullet.tscn")

	rarity = Rarity.COMMON
	type = Type.Armory
	turretID = TurretID.MINI_SENTRY_TURRET
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseProjectileSpeed = TurretManager.getTurretStat(turretID,"projectileSpeed")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	baseReloadTime = TurretManager.getTurretStat(turretID,"reloadTime")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")

	upgradeTier = 0
	level = 1

	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $MiniSentryTurretTop # TODO CHANGE PER TURRET
	bodyCollisionShape = $CollisionShape2D
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = baseAttackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = baseReloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth
	baseHealth = maxHealth

	isPlaced = true

	applyUpgrade()

func reloadAnimation():
	var reloadFrames : int = 2
	for x in range(reloadFrames):
		if x == 0:
			topSprite.frame = 1
		if x == 1:
			topSprite.frame = 0
		await get_tree().create_timer((reloadTime / reloadFrames)).timeout


func attack():

	if shotReady and enemiesInRange.size() > 0 and isPlaced:

		var enemy = EntityManager.getClosestEnemyFromSprite($".")

		shotReady = false
		if is_instance_valid(enemy) and isPlaced:
			var proj = projectile.instantiate()
			proj.position = position
			proj.linear_velocity = (enemy.global_position - global_position).normalized() * projectileSpeed
			var dif = self.global_position.angle_to_point(enemy.global_position)
			proj.rotation = proj.rotation + dif
			proj.damage = damage
			proj.shooter = self
			get_parent().add_child(proj)

			reloadTimer.start()
			reloadAnimation()

			topSprite.look_at(enemy.global_position)
			topSprite.rotate(PI/2)

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
	projectileSpeed = (baseProjectileSpeed + (baseProjectileSpeed * scaleFactor * upgradeTier))
	reloadTime = max(.3,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	reloadTimer.wait_time = reloadTime
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	refreshUI(self)
