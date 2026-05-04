extends Turret

class_name GoldMineTurret

@export var baseGoldProduced : int
@export var goldProductionTime: float
@export var goldIncreaseScale: float
var baseProductionTime : float
var generateTimer : Timer

var moneyGenerated : int

func _ready() -> void:
	projectile = preload("res://Projectile Scenes/gold coin.tscn")

	rarity = Rarity.LEGENDARY
	type = Type.Midieval
	turretID = TurretID.GOLD_MINE_TURRET
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseHealth = maxHealth
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseProjectileSpeed = TurretManager.getTurretStat(turretID,"projectileSpeed")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	baseReloadTime = TurretManager.getTurretStat(turretID,"reloadTime")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	baseGoldProduced = TurretManager.getTurretStat(turretID,"baseGoldProduced")
	goldProductionTime = TurretManager.getTurretStat(turretID,"generateTime")
	baseProductionTime = goldProductionTime
	goldIncreaseScale = TurretManager.getTurretStat(turretID,"goldIncreaseScale")
	
	moneyGenerated = baseGoldProduced

	level = 1
	upgradeTier = 0

	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	generateTimer = $GenerateTimer
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth

	generateTimer.wait_time = goldProductionTime
	
	isPlaced = true
	
	applyUpgrade()

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
	CityManager.currentMoney += moneyGenerated
	$"Money Label".text = "$" + str(moneyGenerated)
	$AnimationPlayer.play("Generate Gold")

func _on_generate_timer_timeout() -> void:
	generateMoney()

func _on_select_area_mouse_entered() -> void:
	showUI(self)

func _on_select_area_mouse_exited() -> void:
	hideUI()

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = (baseDamage + (baseDamage * scaleFactor * upgradeTier))
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	projectileSpeed = (baseProjectileSpeed + (baseProjectileSpeed * scaleFactor * upgradeTier))
	reloadTime = max(1,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	reloadTimer.wait_time = reloadTime
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	moneyGenerated = int((baseGoldProduced + (baseGoldProduced * goldIncreaseScale * upgradeTier)))
	goldProductionTime = max(1,(baseProductionTime - (baseProductionTime * scaleFactor * upgradeTier)))
	generateTimer.wait_time = goldProductionTime
	refreshUI(self)
