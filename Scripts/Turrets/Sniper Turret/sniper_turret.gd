extends Turret

class_name SniperTurret

@onready var particle = $TurretTop/ShotParticle

var baseReloadChance
var reloadChance

var baseSilverBulletChance
var silverBulletChance

var silverBulletDamageMultiplier

var targetEnemy

func _ready() -> void:

	rarity = Rarity.COMMON
	type = Type.Midieval
	turretID = TurretID.SNIPER_TURRET

	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	baseHealth = TurretManager.getTurretStat(turretID,"health")
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	baseReloadTime = TurretManager.getTurretStat(turretID,"reloadTime")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	baseSilverBulletChance = TurretManager.getTurretStat(turretID,"silverBulletChance")
	silverBulletDamageMultiplier = TurretManager.getTurretStat(turretID,"silverBulletDamageMultiplier")
	baseReloadChance = TurretManager.getTurretStat(turretID,"reloadChance")

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
	selectAreaCollisionShape = $SelectArea/CollisionShape2D
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	maxHealth = baseHealth
	health = maxHealth
	reloadChance = baseReloadChance
	silverBulletChance = baseSilverBulletChance

	hideRange()

	applyUpgrade()

	isPlaced = true

func _process(delta: float) -> void:
	if enemiesInRange.size() > 0:
		targetEnemy = getHighestEnemyHealthInRange()
		if is_instance_valid(targetEnemy):
			topSprite.look_at(targetEnemy.global_position)
			topSprite.rotate(PI/2)
			if shotReady:
				attack()


func attack():
	if shotReady and enemiesInRange.size() > 0 and isPlaced:

		var enemy = targetEnemy

		if is_instance_valid(enemy) and isPlaced:
			particle.emitting = true
			if level >= 3:
				if randf_range(0,100) <= silverBulletChance:
					EntityManager.enemyTakeDamage(DamagePacket.new(damage * silverBulletDamageMultiplier, DamagePacket.Type.TURRET, self, [], {}), enemy)
				else:
					EntityManager.enemyTakeDamage(DamagePacket.new(damage, DamagePacket.Type.TURRET, self, [], {}), enemy)
			else:
				EntityManager.enemyTakeDamage(DamagePacket.new(damage, DamagePacket.Type.TURRET, self, [], {}), enemy)

			shotReady = false
			reloadTimer.start()
			reloadAnimation()

			topSprite.look_at(enemy.global_position)
			topSprite.rotate(PI/2)
		

func reloadAnimation():

	topSprite.play("Ready")

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

func getHighestEnemyHealthInRange() -> Enemy:
	var valid_enemies = enemiesInRange.filter(func(enemy): return is_instance_valid(enemy))
	
	if valid_enemies.size() == 0:
		return null
		
	var highest_health_enemy = valid_enemies.reduce(
		func(max_enemy: Enemy, current_enemy: Enemy) -> Enemy:
			return current_enemy if current_enemy.maxHealth > max_enemy.maxHealth else max_enemy
	)
	
	return highest_health_enemy

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = (baseDamage + (baseDamage * scaleFactor * upgradeTier))
	#attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	reloadTime = max(1,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	reloadTimer.wait_time = reloadTime
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	reloadChance = (baseReloadChance + (baseReloadChance * scaleFactor * upgradeTier))
	silverBulletChance = (baseSilverBulletChance + (baseSilverBulletChance * scaleFactor * upgradeTier))
	silverBulletDamageMultiplier += 0.1
	health = maxHealth
	refreshUI(self)
