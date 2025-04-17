extends Turret

class_name MiniSentryTurret

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	projectile = preload("res://Projectile Scenes/sentry bullet.tscn")

	rarity = Rarity.COMMON
	type = Type.Armory

	turretName = "Mini Sentry Turret"
	price = 25
	maxHealth = 25
	baseDamage = 7
	baseProjectileSpeed = 500
	baseAttackRange = 100
	baseReloadTime = .5
	upgradeTier = 0
	armor = 30
	level = 1
	baseBuildTime = 3

	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $MiniSentryTurretTop # TODO CHANGE PER TURRET
	bodyCollisionShape = $CollisionShape2D
	attackRange = baseAttackRange
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = baseAttackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = baseReloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth

	hit.connect(EntityManager.entityTakeDamage)
	upgrade.connect(EntityManager.applyUpgradeTier)

	upgradeTier = EntityManager.getUpgradeTier(turretName)

	for x in range(upgradeTier):
		upgrade.emit(self)

		# Check if in devmode durring runtime
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

func reloadAnimation():
	var reloadFrames : int = 2
	for x in range(reloadFrames):
		if x == 0:
			topSprite.frame = 1
		if x == 1:
			topSprite.frame = 0
		await get_tree().create_timer((reloadTime / reloadFrames)).timeout


func shoot(enemy):
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
