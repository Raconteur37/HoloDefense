extends Turret

class_name GoldMineTurret

@onready var scanTimer : Timer = $ScanTimer

@export var baseGoldProduced : int
@export var goldProductionTime: float
@export var goldIncreaseScale: float
var baseProductionTime : float
var generateTimer : Timer

var moneyGenerated : int

var baseExtraChance : float
var extraChance : float

var baseExtraGold : int
var extraGold : int

var baseKillChance : float
var killChance : float

var scanTime

var turretsInRange = []

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		onDeath()

func onDeath():
	for turret : Turret in turretsInRange:
		if is_instance_valid(turret):
			if turret.goldenBuff:
				if turret.turretProviders["golden"] == self:
					turret.removeGoldenBuff()

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
	baseExtraGold = TurretManager.getTurretStat(turretID,"extraGold")
	baseExtraChance = TurretManager.getTurretStat(turretID,"extraGoldChance")
	baseKillChance = TurretManager.getTurretStat(turretID,"extraGoldKillChance")
	scanTime = TurretManager.getTurretStat(turretID,"scanTime")
	
	moneyGenerated = baseGoldProduced

	level = XpManager.getCurrentLevel(turretID)
	upgradeTier = 0

	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeArea = $RangeArea
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	bottomSprite = $TurretBottom
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
	extraGold = baseExtraGold
	extraChance = baseExtraChance
	killChance = baseKillChance

	generateTimer.wait_time = goldProductionTime
	
	isPlaced = true
	
	if level >= 3:
		scanTimer.wait_time = scanTime
		scanTimer.start()
	
	applyUpgrade()

func attack():

	if shotReady and enemiesInRange.size() > 0 and isPlaced:
		var enemy = EntityManager.getClosestEnemyFromSprite($".")

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
	StatManager.addStat(turretID,"gold_produced",moneyGenerated)
	XpManager.addXp(turretID)
	$"Money Label".text = "$" + str(moneyGenerated)
	$AnimationPlayer.play("Generate Gold")
	if level >= 2:
		await get_tree().create_timer(1).timeout
		var rand = randf_range(0,100)
		if rand <= extraChance:
			CityManager.currentMoney += extraGold
			StatManager.addStat(turretID,"gold_produced",extraGold)
			XpManager.addXp(turretID)
			$"Money Label".text = "$" + str(extraGold)
			$AnimationPlayer.play("Extra Generate")

func _on_generate_timer_timeout() -> void:
	generateMoney()

func _on_scan_timer_timeout() -> void:
	if not isPlaced:
		return
	for x in rangeArea.get_overlapping_areas():
		var turret = x.get_parent()
		if turret is Turret and turret != self:
			if turret not in turretsInRange:
				turretsInRange.append(turret)
			if not turret.goldenBuff:
				turret.giveGoldenBuff(self)

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
	extraGold = int((baseExtraGold + (baseExtraGold * goldIncreaseScale * upgradeTier)))
	extraChance = (baseExtraChance + (baseExtraChance * scaleFactor * upgradeTier))
	killChance = (baseKillChance + (baseKillChance * scaleFactor * upgradeTier))
	goldProductionTime = max(1,(baseProductionTime - (baseProductionTime * scaleFactor * upgradeTier)))
	generateTimer.wait_time = goldProductionTime
	refreshUI(self)
