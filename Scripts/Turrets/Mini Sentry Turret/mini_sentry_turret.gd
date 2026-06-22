extends Turret

class_name MiniSentryTurret

var speedupTimer : Timer
var speedup : bool = false
var speedupReloadTime : float
var prevReloadTime : float

@onready var repairTimer : Timer = $RepairTimer
var repairTickTime : float
var repairAmount : int
var repairTime : float

var maxArmor

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
	maxArmor = armor
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
	topSprite = $MiniSentryTurretTop # TODO CHANGE PER TURRET
	bodyCollisionShape = $CollisionShape2D
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = baseAttackRange
	reloadTime = baseReloadTime
	prevReloadTime = reloadTime
	reloadTimer.wait_time = baseReloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth
	baseHealth = maxHealth
	
	speedupTimer = $SpeedupTimer
	speedupTimer.wait_time = TurretManager.getTurretStat(turretID,"killSpeedupTime")
	speedupReloadTime = TurretManager.getTurretStat(turretID,"reloadTimeSpeedupValue")

	repairTickTime = TurretManager.getTurretStat(turretID,"repairTickTime")
	repairAmount = TurretManager.getTurretStat(turretID,"repairAmount")
	repairTime = TurretManager.getTurretStat(turretID,"repairTime") # How long before like the turret doesnt take dmg
	repairTimer.wait_time = repairTime

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
			proj.velocity = proj.global_position.direction_to(enemy.global_position) * projectileSpeed
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

func startSpeedEvent():
	speedupTimer.start()
	reloadTime = speedupReloadTime
	reloadTimer.start()
	reloadTimer.wait_time = reloadTime
	refreshUI(self)

func stopRepairEvent():
	repairTimer.start()

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = (baseDamage + (baseDamage * scaleFactor * upgradeTier))
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	projectileSpeed = (baseProjectileSpeed + (baseProjectileSpeed * scaleFactor * upgradeTier))
	reloadTime = max(.3,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	prevReloadTime = reloadTime
	reloadTimer.wait_time = reloadTime
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	refreshUI(self)


func _on_speedup_timer_timeout() -> void:
	reloadTime = prevReloadTime
	reloadTimer.wait_time = reloadTime
	refreshUI(self)

func _on_repair_timer_timeout() -> void:
	while armor < maxArmor:
		if not repairTimer.is_stopped():
			break
		armor += repairAmount
		refreshUI(self)
		await get_tree().create_timer(repairTickTime).timeout
