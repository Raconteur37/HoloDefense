extends Turret

class_name VoodooTurret

@export var curseDuration : float
@export var curseDamageAmp : float
@export var curseChance : float

var baseCurseDuration : float
var baseCurseDamageAmp : float
var baseCurseChance : float

var curseExplosionRadius : float
var baseExplosionRadius : float

var damageReduction
var baseDamageReduction

func _ready() -> void:
	projectile = preload("res://Projectile Scenes/voodoodoll.tscn")

	rarity = Rarity.COMMON
	type = Type.Magic
	turretID = TurretID.VOODOO_TURRET
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
	baseCurseDuration = TurretManager.getTurretStat(turretID,"curseDuration")
	baseCurseDamageAmp = TurretManager.getTurretStat(turretID,"curseDamageAmp")
	baseCurseChance = TurretManager.getTurretStat(turretID,"curseChance")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	baseExplosionRadius = TurretManager.getTurretStat(turretID,"curseExplosionRadius")
	baseDamageReduction = TurretManager.getTurretStat(turretID,"curseDamageReduction")

	curseChance = baseCurseChance
	curseDuration = baseCurseDuration
	curseDamageAmp = baseCurseDamageAmp

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
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth
	curseExplosionRadius = baseExplosionRadius
	damageReduction = baseDamageReduction

	isPlaced = true

	applyUpgrade()

func attack():

	if shotReady and enemiesInRange.size() > 0 and isPlaced:

		var enemy = filterEnemy()

		if is_instance_valid(enemy) and isPlaced:

			shotReady = false

			var proj = projectile.instantiate()
			applyProjectileModifiers(proj)
			proj.position = position
			proj.velocity = proj.global_position.direction_to(enemy.global_position) * projectileSpeed

			var dif = self.global_position.angle_to_point(enemy.global_position)

			proj.rotation = proj.rotation + dif
			proj.damage = damage
			proj.shooter = self


			proj.curseTime = curseDuration
			proj.curseDamageAmp = curseDamageAmp
			var rand = randf_range(0,100)
			if rand <= curseChance:
				proj.curse = true


			get_parent().add_child(proj)

			reloadTimer.start()
			reloadAnimation()


func reloadAnimation():

	var frames : int = 7

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
				topSprite.frame = 0
		await get_tree().create_timer((reloadTime / frames)).timeout

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = (baseDamage + (baseDamage * scaleFactor * upgradeTier))
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	reloadTime = max(1,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	reloadTimer.wait_time = reloadTime
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	curseChance = (baseCurseChance + (baseCurseChance * scaleFactor * upgradeTier))
	curseDamageAmp = (baseCurseDamageAmp + (baseCurseDamageAmp * scaleFactor * upgradeTier))
	curseDuration = (baseCurseDuration + (baseCurseDuration * scaleFactor * upgradeTier))
	damageReduction = (baseDamageReduction + (baseDamageReduction * scaleFactor * upgradeTier))
	curseExplosionRadius = (baseExplosionRadius + (baseExplosionRadius * scaleFactor * upgradeTier))
	health = maxHealth
	refreshUI(self)
