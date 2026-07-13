extends Turret

class_name SeismicTurret

@onready var reloadTickTimer : Timer = $ReloadTickDamageTimer
@onready var reloadParticle : CPUParticles2D = $SeismicReloadParticle

var attackParticle
var tickTime
var tickDamage
var baseTickDamage

var chainRange
var baseChainRange

func _ready() -> void:
	rarity = Rarity.RARE
	type = Type.Elemental
	turretID = TurretID.SEISMIC_TURRET
	turretName =  TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseHealth = maxHealth
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	baseReloadTime = TurretManager.getTurretStat(turretID,"reloadTime")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	baseTickDamage = TurretManager.getTurretStat(turretID,"reloadShockwaveDamage")
	tickTime = TurretManager.getTurretStat(turretID,"reloadShockwaveTickTime")
	baseChainRange = TurretManager.getTurretStat(turretID,"chainRange")
	reloadTickTimer.wait_time = tickTime

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
	attackParticle = $SeismicEarthquakeParticle
	rangeArea = $RangeArea
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	health = maxHealth
	tickDamage = baseTickDamage
	chainRange = baseChainRange

	applyUpgrade()
	
	isPlaced = true
	
func attack():

	if shotReady and enemiesInRange.size() > 0 and isPlaced:

		shotReady = false

		attackParticle.emitting = true

		for x in range(4):
			for area in rangeArea.get_overlapping_areas():
				var enemy = area.get_parent()
				if enemy.is_in_group("Enemy"):
					EntityManager.enemyTakeDamage(DamagePacket.new(damage, DamagePacket.Type.TURRET, self, [], {}), enemy)
			await get_tree().create_timer((.3)).timeout

		reloadTimer.start()
		if level >= 2:
			reloadTickTimer.start()
			reloadParticle.emitting = true
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
	reloadTickTimer.stop()
	reloadParticle.emitting = false

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = (baseDamage + (baseDamage * scaleFactor * upgradeTier))
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	reloadTime = max(1,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	reloadTimer.wait_time = reloadTime
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	tickDamage = (baseTickDamage + (baseTickDamage * scaleFactor * upgradeTier))
	chainRange = (baseChainRange + (baseChainRange * scaleFactor * upgradeTier))
	refreshUI(self)


func _on_reload_tick_damage_timer_timeout() -> void:
	for area in rangeArea.get_overlapping_areas():
		var enemy = area.get_parent()
		if enemy.is_in_group("Enemy"):
			EntityManager.enemyTakeDamage(DamagePacket.new(tickDamage, DamagePacket.Type.TURRET, self, [], {}), enemy)
	reloadTickTimer.start()
