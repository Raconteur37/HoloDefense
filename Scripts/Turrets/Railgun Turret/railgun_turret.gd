extends Turret

class_name RailgunTurret

@export var basePierce : int = 2

var pierce

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	projectile = preload("res://Projectile Scenes/railgunbullet.tscn")

	rarity = Rarity.RARE
	type = Type.Armory

	const turretName : String = "Railgun Turret"
	price = 75
	maxHealth = 50
	baseDamage = 100
	baseProjectileSpeed = 150
	baseAttackRange = 500
	baseReloadTime = 10.0
	upgradeTier = 0
	armor = 30
	level = 1
	baseBuildTime = 20

	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $RailgunTurretTop # CHANGE THIS
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
	pierce = basePierce

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
		var dummy2 = load("res://Enemy Scenes/Dummy.tscn")
		dummy2 = dummy2.instantiate()
		dummy2.global_position = to_local(global_position)
		dummy2.global_position.x += 150
		add_child(dummy2)

func attack():

	if shotReady and enemiesInRange.size() > 0 and isPlaced:
		var enemy = EntityManager.getClosestEnemyFromSprite($".")

		shotReady = false
		if is_instance_valid(enemy) and isPlaced:
			var proj = projectile.instantiate()
			proj.position = position
			proj.maxEnemyPierce = pierce
			proj.velocity = (enemy.global_position - global_position).normalized() * projectileSpeed
			var dif = self.global_position.angle_to_point(enemy.global_position)

			proj.rotation = proj.rotation + dif
			proj.damage = damage
			proj.shooter = self
			get_parent().add_child(proj)

			reloadTimer.start()
			reloadAnimation()

			#dif = topSprite.global_position.angle_to_point(enemy.global_position)
			topSprite.look_at(enemy.global_position)
			topSprite.rotate(PI/2)

			$RailgunTurretTop/RailgunShoot.emitting = true

func reloadAnimation():

	var frames : int = 10

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
				topSprite.frame = 0
		await get_tree().create_timer((reloadTime / frames)).timeout


func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true
