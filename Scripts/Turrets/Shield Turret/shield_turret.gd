extends Turret

class_name ShieldTurret

@onready var armorTimer = $ArmorProvider

var particle

var baseKnockbackVelocity
var baseArmorProvided
var baseArmorTime

var knockbackVel
var armorProvided
var armorTime
var damageResistance

var damageResActive : bool = false

func _ready() -> void:

	rarity = Rarity.COMMON
	turretID = TurretID.SHIELD_TURRET
	type = TurretManager.getTurretTypeEnum(turretID)
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	baseHealth = TurretManager.getTurretStat(turretID,"health")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	baseReloadTime = TurretManager.getTurretStat(turretID,"reloadTime")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	baseKnockbackVelocity = TurretManager.getTurretStat(turretID,"knockbackVelocity")
	damageResistance = TurretManager.getTurretStat(turretID,"damageResistance")
	baseArmorProvided = TurretManager.getTurretStat(turretID,"armorProvided")
	baseArmorTime = TurretManager.getTurretStat(turretID,"armorTime")
	upgradeTier = 0
	level = XpManager.getCurrentLevel(turretID)

	particle = $BubblePop

	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	bottomSprite = $TurretBottom
	selectArea = $SelectArea
	rangeArea = $RangeArea
	bodyCollisionShape = $CollisionShape2D
	selectAreaCollisionShape = $SelectArea/CollisionShape2D
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	knockbackVel = baseKnockbackVelocity
	armorProvided = baseArmorProvided
	armorTime = baseArmorTime
	maxHealth = baseHealth
	health = maxHealth

	armorTimer.wait_time = armorTime
	
	if level >= 2:
		armorTimer.start()

	getAdjacentTurrets()

	hideRange()

	applyUpgrade()

	isPlaced = true

func attack():
	if shotReady and enemiesInRange.size() > 0 and isPlaced:

		shotReady = false

		particle.emitting = true
		
		spin()

		for x in range(4):
			for area in rangeArea.get_overlapping_areas():
				var enemy = area.get_parent()
				if enemy.is_in_group("Enemy"):
					enemy.applyKnockback(global_position,knockbackVel)
					StatManager.addStat(turretID,"enemies_pushed",1)
					XpManager.addXp(turretID)
			await get_tree().create_timer((.3)).timeout

		reloadTimer.start()

func spin():
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(topSprite, "rotation_degrees", 360.0, 0.3).as_relative()


func getAdjacentTurrets():
	return PlacementManager.getAdjacentTurrets(global_position, false)

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true

func giveArmor():
	pass

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	reloadTime = max(1,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	reloadTimer.wait_time = reloadTime
	armorTime = max(1,(baseArmorTime - (baseArmorTime * scaleFactor * upgradeTier)))
	armorTimer.wait_time = armorTime
	knockbackVel = (baseKnockbackVelocity + (baseKnockbackVelocity * scaleFactor * upgradeTier))
	armorProvided = round((baseArmorProvided + (baseArmorProvided * scaleFactor * upgradeTier)))
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	refreshUI(self)


func _on_armor_provider_timeout() -> void:
	var turretList = getAdjacentTurrets()
	if turretList.size() >= 1:
		for turret in turretList:
			if turret.turretID == TurretID.SHIELD_TURRET:
				damageResActive = true
				refreshUI(self)
				break
			damageResActive = false
			refreshUI(self)
		if level >= 3:
			for turret in turretList:
				if turret.turretID != TurretID.SHIELD_TURRET:
					turret.armor += armorProvided
					turret.refreshUI(turret)
	else:
		damageResActive = false
		refreshUI(self)
	
