extends Turret

class_name GoldMineTurret

@export var baseGoldProduced : int = 2

func _ready() -> void:
	projectile = preload("res://Projectile Scenes/gold coin.tscn")

	rarity = Rarity.LEGENDARY
	type = Type.Midieval

	turretName = "Gold Mine Turret"
	price = 45
	maxHealth = 15
	baseDamage = 5
	baseProjectileSpeed = 300
	baseAttackRange = 150
	baseReloadTime = 3
	upgradeTier = 0
	armor = 20
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
		get_parent().add_child(proj)

		reloadTimer.start()
		reloadAnimation()

func reloadAnimation():

	var frames : int = 2

	for x in range(frames):
		match x:
			0:
				topSprite.frame = 1
			1:
				topSprite.frame = 0
		await get_tree().create_timer((reloadTime)).timeout

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true

func generateMoney():
	var moneyGenerated : int = floor(pow(level,.5)) + baseGoldProduced
	GameManager.currentMoney += moneyGenerated
	$"Money Label".text = "$" + str(moneyGenerated)
	$AnimationPlayer.play("Generate Gold")

func _on_generate_timer_timeout() -> void:
	if isPlaced:
		generateMoney()
