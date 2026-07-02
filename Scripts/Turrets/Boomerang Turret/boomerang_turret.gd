extends Turret
class_name BoomerangTurret

@export var baseExecutionChance: float
var basePierce
var pierce

func _ready() -> void:
	projectile = preload("res://Projectile Scenes/boomerang.tscn")
	rarity = Rarity.COMMON
	type = Type.Dark
	turretID = TurretID.BOOMERANG_TURRET
	turretName = TurretManager.getTurretStat(turretID, "name")
	price = TurretManager.getTurretStat(turretID, "price")
	maxHealth = TurretManager.getTurretStat(turretID, "health")
	baseHealth = maxHealth
	baseDamage = TurretManager.getTurretStat(turretID, "damage")
	baseProjectileSpeed = TurretManager.getTurretStat(turretID, "projectileSpeed")
	baseAttackRange = TurretManager.getTurretStat(turretID, "range")
	baseReloadTime = TurretManager.getTurretStat(turretID, "reloadTime")
	armor = TurretManager.getTurretStat(turretID, "armor")
	baseBuildTime = TurretManager.getTurretStat(turretID, "constructionTime")
	scaleFactor = TurretManager.getTurretStat(turretID, "scaleFactor")
	basePierce = TurretManager.getTurretStat(turretID, "pierce")
	upgradeTier = 0
	level = 1
	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d, attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth
	pierce = basePierce
	isPlaced = true


	applyUpgrade()

func attack() -> void:
	if not shotReady or enemiesInRange.is_empty() or not isPlaced:
		return
	var enemy = EntityManager.getClosestEnemyFromSprite(self)
	if not is_instance_valid(enemy):
		return

	shotReady = false

	var proj = projectile.instantiate()
	
	applyProjectileModifiers(proj)
	
	proj.damage = damage
	proj.shooter = self
	proj.pierce = pierce
	proj.speed = projectileSpeed

	get_parent().add_child(proj)
	proj.launch(global_position, enemy.global_position)

	topSprite.look_at(enemy.global_position)
	topSprite.rotate(PI / 2)

	reloadTimer.start()
	reloadAnimation()


func reloadAnimation() -> void:
	topSprite.hide()
	await get_tree().create_timer(reloadTime).timeout
	topSprite.show()


func _on_range_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		enemiesInRange.append(body)


func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)


func _on_reload_timer_timeout() -> void:
	shotReady = true


func _on_select_area_mouse_entered() -> void:
	showUI(self)


func _on_select_area_mouse_exited() -> void:
	hideUI()


func applyUpgrade() -> void:
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = baseDamage + (baseDamage * scaleFactor * upgradeTier)
	attackRange = baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier)
	projectileSpeed = baseProjectileSpeed + (baseProjectileSpeed * scaleFactor * upgradeTier)
	reloadTime = max(1, baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier))
	reloadTimer.wait_time = reloadTime
	maxHealth = baseHealth + (baseHealth * scaleFactor * upgradeTier)
	health = maxHealth
	pierce = int(basePierce + (basePierce * scaleFactor * upgradeTier))
	refreshUI(self)
