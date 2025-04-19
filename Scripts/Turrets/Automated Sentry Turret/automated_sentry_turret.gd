extends Turret

class_name AutomatedSentryTurret

var shootTimer : Timer
var particle

@export var maxBullets : int = 150 # Bullets shot before needing to reload
@export var shotTime : float = .1 # The interval of which each bullet will be shot

var currentBullets


func _ready() -> void:
	rarity = Rarity.COMMON
	type = Type.Modern

	const turretName : String = "Automated Sentry Turret"
	price = 20
	maxHealth = 20
	baseDamage = 20
	baseProjectileSpeed = 400
	baseAttackRange  = 200
	baseReloadTime = 3.5
	upgradeTier = 0
	armor = 0
	level = 1
	baseBuildTime = 5
	projectile = preload("res://Projectile Scenes/sentry bullet.tscn")
	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	shootTimer = $ShootTimer
	particle = $TurretTop/AutomatedSentryTurretFire
	shootTimer.wait_time = shotTime
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth
	currentBullets = maxBullets

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
	if shotReady and enemiesInRange.size() > 0 and isPlaced and currentBullets > 0 and shootTimer.is_stopped():
		shoot(EntityManager.getClosestEnemyFromSprite($"."))
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true
	if not beaconBuffActive:
		BeaconManager.applyBeaconBuffs()

func shoot(enemy):
	if is_instance_valid(enemy) and isPlaced:

		var animInstance = currentBullets % 4

		currentBullets -= 1

		var proj = projectile.instantiate()
		proj.position = position
		proj.linear_velocity = (enemy.global_position - global_position).normalized() * projectileSpeed
		proj.linear_velocity = proj.linear_velocity + Vector2(randf_range(-100,100),randf_range(-100, 100))

		var dif = self.global_position.angle_to_point(enemy.global_position)

		proj.rotation = proj.rotation + dif
		proj.damage = damage
		proj.shooter = self
		get_parent().add_child(proj)

		#dif = topSprite.global_position.angle_to_point(enemy.global_position)
		topSprite.look_at(enemy.global_position)
		topSprite.rotate(PI/2)

		match animInstance:
			0:
				topSprite.frame = 1
				particle.position.x = 0
			1:
				topSprite.frame = 2
				particle.position.x += 9
			2:
				topSprite.frame = 3
				particle.position.x -= 18
			3:
				topSprite.frame = 4
				particle.position.x += 9

		particle.emitting = true

		if currentBullets <= 0:
			reloadTimer.start()
			reloadAnimation()

		shootTimer.start()

func reloadAnimation():

	shotReady = false

	topSprite.frame = 0


func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true
	currentBullets = maxBullets
