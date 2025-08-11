extends Turret

class_name SpiderTurret


@export var basePoisonChance : float
@export var basePoisonDuration : float
@export var basePoisonDamage : float

var poisonDamage
var poisonDuration
var poisonChance

func _ready() -> void:
	rarity = Rarity.COMMON
	type = Type.Biological

	turretName = TurretManager.getTurretStat("spider_turret","name")
	price = TurretManager.getTurretStat("spider_turret","price")
	maxHealth = TurretManager.getTurretStat("spider_turret","health")
	baseDamage = TurretManager.getTurretStat("spider_turret","damage")
	baseProjectileSpeed = TurretManager.getTurretStat("spider_turret","projectileSpeed")
	baseAttackRange = TurretManager.getTurretStat("spider_turret","range")
	baseReloadTime = TurretManager.getTurretStat("spider_turret","reloadTime")
	armor = TurretManager.getTurretStat("spider_turret","armor")
	baseBuildTime = TurretManager.getTurretStat("spider_turret","constructionTime")
	poisonChance = TurretManager.getTurretStat("spider_turret","poisonChance")
	poisonDuration = TurretManager.getTurretStat("spider_turret","poisonDuration")
	poisonDamage = TurretManager.getTurretStat("spider_turret","poisonDamage")

	level = 1
	upgradeTier = 0

	projectile = preload("res://Projectile Scenes/poisondart.tscn")
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
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth
	poisonChance = basePoisonChance
	poisonDamage = basePoisonDamage
	poisonDuration = basePoisonDuration

	hit.connect(EntityManager.entityTakeDamage)
	upgrade.connect(EntityManager.applyUpgradeTier)

	upgradeTier = EntityManager.getUpgradeTier(turretName)

	for x in range(upgradeTier):
		upgrade.emit(self)

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

			proj.poisonChance = poisonChance
			proj.poisonDamage = poisonDamage
			proj.poisonTime = poisonDuration


			get_parent().add_child(proj)

			reloadTimer.start()
			reloadAnimation()

			#dif = topSprite.global_position.angle_to_point(enemy.global_position)
			topSprite.look_at(enemy.global_position)
			topSprite.rotate(PI/2)

func reloadAnimation():

	var frames : int = 6

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
		await get_tree().create_timer((reloadTime / frames)).timeout

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true
