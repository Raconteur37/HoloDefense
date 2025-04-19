extends Turret

class_name VoodooTurret

@export var curseDuration : float = 3
@export var curseDamageAmp : float = .20
@export var curseChance : float = 99

func _ready() -> void:
	projectile = preload("res://Projectile Scenes/voodoodoll.tscn")

	rarity = Rarity.COMMON
	type = Type.Magic

	turretName = "Voodoo Turret"
	price = 20
	maxHealth = 20
	baseDamage = 9
	baseProjectileSpeed = 300
	baseAttackRange = 200
	baseReloadTime = 2.5
	upgradeTier = 0
	armor = 0
	level = 1
	baseBuildTime = 5

	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
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
	if GameManager.previewMode:
		var dummy = load("res://Enemy Scenes/Dummy.tscn")
		dummy = dummy.instantiate()
		dummy.global_position = to_local(global_position)
		dummy.global_position.x += 100
		add_child(dummy)

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
		proj.linear_velocity = (enemy.global_position - global_position).normalized() * projectileSpeed

		var dif = self.global_position.angle_to_point(enemy.global_position)

		proj.rotation = proj.rotation + dif
		proj.damage = damage
		proj.shooter = self

		proj.curseChance = curseChance
		proj.curseTime = curseDuration
		proj.curseDamageAmp = curseDamageAmp


		get_parent().add_child(proj)

		reloadTimer.start()
		reloadAnimation()


func reloadAnimation():

	var frames : int = 7

	for x in range(frames):
		match x:
			0:
				topSprite.frame = 1
			1:
				topSprite.frame = 2
			2:
				topSprite.frame = 3
			3:
				topSprite.frame = 4
			4:
				topSprite.frame = 5
			5:
				topSprite.frame = 6
			6:
				topSprite.frame = 0
		await get_tree().create_timer((reloadTime / frames)).timeout

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true
