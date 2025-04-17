extends Turret

class_name ReaperTurret

@export var baseExecutionChance : float = 2

var executionChance

func _ready() -> void:
	projectile = preload("res://Projectile Scenes/sythe.tscn")

	rarity = Rarity.SUPER_RARE
	type = Type.Dark

	turretName = "Reaper Turret"
	price = 35
	maxHealth = 35
	baseDamage = 15
	baseProjectileSpeed = 250
	baseAttackRange = 250
	baseReloadTime = 3
	upgradeTier = 0
	armor = 0
	level = 1
	baseBuildTime = 9

	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $ReaperTurretTop
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	attackRange = baseAttackRange
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth
	executionChance = baseExecutionChance

	hit.connect(EntityManager.entityTakeDamage)
	upgrade.connect(EntityManager.applyUpgradeTier)

	upgradeTier = EntityManager.getUpgradeTier(turretName)

	for x in range(upgradeTier):
		upgrade.emit(self)

	if DeveloperMode.inDevMode and not PlacementManager.inGame:
		isPlaced = true
		GameManager.addTurretToDict(self)
		health = 9999

func _process(delta: float) -> void:
	if shotReady and enemiesInRange.size() > 0 and isPlaced:
		shoot(EntityManager.getClosestEnemyFromSprite($"."))
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true
	if not beaconBuffActive:
		BeaconManager.applyBeaconBuffs()

func shoot(enemy):
	shotReady = false
	if is_instance_valid(enemy) and isPlaced:
		var proj = projectile.instantiate()
		proj.position = position
		proj.oneShotChance = executionChance
		proj.linear_velocity = (enemy.global_position - global_position).normalized() * projectileSpeed

		var dif = self.global_position.angle_to_point(enemy.global_position)

		proj.rotation = proj.rotation + dif
		proj.damage = damage
		proj.shooter = self
		get_parent().add_child(proj)

		reloadTimer.start()
		reloadAnimation()

		#dif = topSprite.global_position.angle_to_point(enemy.global_position)
		topSprite.look_at(enemy.global_position)
		topSprite.rotate(PI/2)

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
