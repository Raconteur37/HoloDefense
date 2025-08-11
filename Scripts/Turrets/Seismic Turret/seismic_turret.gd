extends Turret

class_name SeismicTurret

var attackParticle

func _ready() -> void:
	rarity = Rarity.RARE
	type = Type.Elemental

	turretName =  TurretManager.getTurretStat("seismic_turret","name")
	price = TurretManager.getTurretStat("seismic_turret","price")
	maxHealth = TurretManager.getTurretStat("seismic_turret","health")
	baseDamage = TurretManager.getTurretStat("seismic_turret","damage")
	baseAttackRange = TurretManager.getTurretStat("seismic_turret","range")
	baseReloadTime = TurretManager.getTurretStat("seismic_turret","reloadTime")
	armor = TurretManager.getTurretStat("seismic_turret","armor")
	baseBuildTime = TurretManager.getTurretStat("seismic_turret","constructionTime")

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
	attackParticle = $SeismicEarthquakeParticle
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
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
		dummy.global_position.x += 50
		add_child(dummy)
		var dummy2 = load("res://Enemy Scenes/Dummy.tscn")
		dummy2 = dummy2.instantiate()
		dummy2.global_position = to_local(global_position)
		dummy2.global_position.x -= 50
		add_child(dummy2)

func attack():

	if shotReady and enemiesInRange.size() > 0 and isPlaced:

		shotReady = false

		attackParticle.emitting = true

		for x in range(4):
			for enemy in $RangeArea.get_overlapping_areas():
				if enemy.get_parent().is_in_group("Enemy"):

					enemy.get_parent().hit.emit(damage,self,enemy.get_parent(),self) # Fix damage type
			await get_tree().create_timer((.3)).timeout

		reloadTimer.start()
		reloadAnimation()


func reloadAnimation():

	var frames : int = 30

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
				topSprite.frame = 7
			7:
				topSprite.frame = 8
			8:
				topSprite.frame = 9
			9:
				topSprite.frame = 10
			10:
				topSprite.frame = 11
			11:
				topSprite.frame = 12
			12:
				topSprite.frame = 13
			13:
				topSprite.frame = 14
			14:
				topSprite.frame = 15
			15:
				topSprite.frame = 16
			16:
				topSprite.frame = 17
			17:
				topSprite.frame = 18
			18:
				topSprite.frame = 19
			19:
				topSprite.frame = 20
			20:
				topSprite.frame = 21
			21:
				topSprite.frame = 22
			22:
				topSprite.frame = 23
			23:
				topSprite.frame = 24
			24:
				topSprite.frame = 25
			25:
				topSprite.frame = 26
			26:
				topSprite.frame = 27
			27:
				topSprite.frame = 28
			28:
				topSprite.frame = 29
			29:
				topSprite.frame = 30
			30:
				topSprite.frame = 0
		await get_tree().create_timer((reloadTime / frames)).timeout

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true
