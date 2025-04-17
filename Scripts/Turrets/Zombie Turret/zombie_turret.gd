extends Turret

class_name ZombieTurret

@export var turnChance : float = 10

var attackTimer : Timer
@export var turnTime : float = 4

func _ready() -> void:

	rarity = Rarity.SUPER_RARE
	type = Type.Dark

	turretName = "Zombie Turret"
	price = 20
	maxHealth = 90
	damage = 1
	baseAttackRange = 30
	upgradeTier = 0
	armor = 0
	level = 1
	baseBuildTime = 5


	line2d = $RangeArea/RangeIndicator
	attackTimer = $AttackTimer
	attackTimer.wait_time = turnTime
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
	damage = baseDamage
	health = maxHealth

	hit.connect(EntityManager.entityTakeDamage)
	upgrade.connect(EntityManager.applyUpgradeTier)

	upgradeTier = EntityManager.getUpgradeTier(turretName)

	for x in range(upgradeTier):
		upgrade.emit(self)

	# Check if in devmode durring runtime
	if DeveloperMode.inDevMode:
		isPlaced = true
		GameManager.addTurretToDict(self)
		health = 9999

func _process(delta: float) -> void:
	if shotReady and enemiesInRange.size() > 0 and isPlaced and attackTimer.is_stopped():
		attackTimer.start()
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true
	if not beaconBuffActive:
		BeaconManager.applyBeaconBuffs()


func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true

func _on_attack_timer_timeout() -> void:
	if enemiesInRange.size() > 0:
		for enemy in enemiesInRange:
			if not enemy.isZombie:
				if randi_range(0,100) <= turnChance:
					enemy.isZombie = true
					enemy.turnTurret = self
					ParticleManager.playZombieTurnParticle(enemy)
		attackTimer.start()
