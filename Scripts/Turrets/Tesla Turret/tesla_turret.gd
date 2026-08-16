extends Turret

class_name TeslaTurret

var damageTickTimer
var attackingTimer
var electricityParticle

var frameOne = false

@export var baseDamageTickTime : float
@export var baseAttackingTime : float

var damageTickTime
var attackingTime

var shooting : bool

var stunTime
var baseChainRange
var chainRange

var maxEnemies

func _ready() -> void:
	projectile = preload("res://Particle Scenes/Turrets/Tesla Turret/Electricity Shoot.tscn")

	rarity = Rarity.SUPER_RARE
	turretID = TurretID.TESLA_TURRET
	type = TurretManager.getTurretTypeEnum(turretID)
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseHealth = maxHealth
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	baseReloadTime = TurretManager.getTurretStat(turretID,"reloadTime")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	baseDamageTickTime = TurretManager.getTurretStat(turretID,"damageTickTime")
	baseAttackingTime = TurretManager.getTurretStat(turretID,"attackingTime")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	stunTime = TurretManager.getTurretStat(turretID,"stunTime")
	baseChainRange = TurretManager.getTurretStat(turretID,"chainRange")
	maxEnemies = TurretManager.getTurretStat(turretID,"maxEnemies")

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
	damageTickTimer = $"Damage Tick Timer"
	attackingTimer = $"Attacking Timer"
	electricityParticle = $TurretTop/ElectricityEmit
	rangeArea = $RangeArea
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	health = maxHealth
	chainRange = baseChainRange
	damageTickTime = baseDamageTickTime
	damageTickTimer.wait_time = damageTickTime
	attackingTime = baseAttackingTime
	attackingTimer.wait_time = attackingTime


	isPlaced = true
	
	applyUpgrade()


func _process(delta: float) -> void:
	if enemiesInRange.size() > 0 and not shooting and attackingTimer.is_stopped() and shotReady and isPlaced:
		topSprite.animation = "Attacking"
		electricityParticle.emitting = true
		shooting = true
		attackingTimer.start()
		if damageTickTimer.is_stopped():
			damageTickTimer.start()
	if not shooting:
		damageTickTimer.stop()

func reloadAnimation():

	attackingTimer.stop()

	reloadTimer.start()

	topSprite.animation = "Ready"

	var frames : int = 4

	for x in range(frames):
		match x:
			0:
				topSprite.frame = 0
			1:
				topSprite.frame = 1
			2:
				topSprite.frame = 2
			3:
				topSprite.frame = 3
		await get_tree().create_timer((reloadTime / frames)).timeout

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true

func _on_damage_tick_timer_timeout() -> void:
	if not shooting:
		damageTickTimer.stop()
		return

	var hit_this_tick = []
	var primary_targets = []

	for x in rangeArea.get_overlapping_areas():
		if primary_targets.size() >= maxEnemies:
			break
			
		var enemy = x.get_parent()
		if enemy.is_in_group("Enemy"):
			primary_targets.append(enemy)
			hit_this_tick.append(enemy)
			strikeEnemy(self.global_position, enemy)

	if level >= 3 and primary_targets.size() > 0:
		var all_enemies = get_tree().get_nodes_in_group("Enemy")
		
		for primary in primary_targets:
			for potential_target in all_enemies:
				if potential_target in hit_this_tick:
					continue
				
				var distance = primary.global_position.distance_to(potential_target.global_position)
				if distance <= chainRange:
					hit_this_tick.append(potential_target)
					strikeEnemy(primary.global_position, potential_target)

	damageTickTimer.start()


func strikeEnemy(start_global_pos: Vector2, target_enemy: Node2D) -> void:
	var shockParticle = projectile.instantiate()
	shockParticle.global_position = to_local(start_global_pos)
	
	get_parent().add_child(shockParticle)

	var start_position = self.global_position
	var end_position = shockParticle.to_local(target_enemy.global_position)
	
	shockParticle.points = [start_position, end_position]

	EntityManager.enemyTakeDamage(DamagePacket.new(damage, DamagePacket.Type.TURRET, self, [], {}), target_enemy)

func _on_attacking_timer_timeout() -> void:
	electricityParticle.emitting = false
	shooting = false
	shotReady = false
	reloadAnimation()

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = (baseDamage + (baseDamage * scaleFactor * upgradeTier))
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	reloadTime = max(1,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	reloadTimer.wait_time = reloadTime
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	attackingTime = (baseAttackingTime + (baseAttackingTime * scaleFactor * upgradeTier))
	chainRange = (baseChainRange + (baseChainRange * scaleFactor * upgradeTier))
	damageTickTime = max(.2,(baseDamageTickTime - (baseDamageTickTime * scaleFactor * upgradeTier)))
	maxEnemies += 1
	refreshUI(self)
