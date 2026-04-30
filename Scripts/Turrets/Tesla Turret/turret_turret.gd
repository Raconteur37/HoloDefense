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

func _ready() -> void:
	projectile = preload("res://Particle Scenes/Turrets/Tesla Turret/Electricity Shoot.tscn")

	rarity = Rarity.SUPER_RARE
	type = Type.Elemental
	turretID = TurretID.TESLA_TURRET
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	baseReloadTime = TurretManager.getTurretStat(turretID,"reloadTime")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	baseDamageTickTime = TurretManager.getTurretStat(turretID,"damageTickTime")
	baseAttackingTime = TurretManager.getTurretStat(turretID,"attackingTime")

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
	damageTickTime = baseDamageTickTime
	damageTickTimer.wait_time = damageTickTime
	attackingTime = baseAttackingTime
	attackingTimer.wait_time = attackingTime

	hit.connect(EntityManager.entityTakeDamage)

	upgradeTier = EntityManager.getUpgradeTier(turretName)

	for x in range(upgradeTier):
		upgrade.emit(self)


	if DeveloperMode.inDevMode:
		isPlaced = true
		GameManager.addTurretToDict(self)
		health = 9999
	if GameManager.previewMode:
		var dummy = load("res://Enemy Scenes/Dummy.tscn")
		dummy = dummy.instantiate()
		dummy.global_position = to_local(global_position)
		dummy.global_position.x += 150
		add_child(dummy)
		var dummy2 = load("res://Enemy Scenes/Dummy.tscn")
		dummy2 = dummy2.instantiate()
		dummy2.global_position = to_local(global_position)
		dummy2.global_position.x -= 150
		add_child(dummy2)

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
	if shooting:
		for x in rangeArea.get_overlapping_areas():
			if x.get_parent().is_in_group("Enemy"):
				var enemy = x.get_parent()
				var shockParticle = projectile.instantiate()
				shockParticle.global_position = global_position

				# Set the positions
				var start_position = Vector2(0,0)
				var end_position = to_local(enemy.global_position)
				var points = [start_position,end_position]

				shockParticle.points = points

				# Add to the scene
				get_parent().add_child(shockParticle)

				EntityManager.enemyTakeDamage(DamagePacket.new(damage, DamagePacket.Type.TURRET, self, [], {}), enemy)
		damageTickTimer.start()
	else:
		damageTickTimer.stop()

func _on_attacking_timer_timeout() -> void:
	electricityParticle.emitting = false
	shooting = false
	shotReady = false
	reloadAnimation()

func _on_select_area_mouse_entered() -> void:
	showUI(self)

func _on_select_area_mouse_exited() -> void:
	hideUI()
