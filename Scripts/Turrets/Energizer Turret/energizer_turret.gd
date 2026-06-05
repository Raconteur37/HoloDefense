extends Turret

class_name EnergizerTurret

var scanTurretsFirstTime: bool = false
var energizeReady: bool = false
var turretsInRange = []
var energizeTimer
var turretsEnergized : int = 0

@export var maxTurretsEnergized: int
@export var energizeTime: float
@export var energizerDamageBuff: float
@export var energizerProjctileSpeedBuff: float
@export var energizerAttackRangeBuff: float
@export var energizerReloadTimeBuff: float

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		onDeath()

func onDeath():
	for turret in turretsInRange:
		if is_instance_valid(turret) and turret.energized:
			removeEnergizerBuffsToTurret(turret)

func _ready() -> void:
	rarity = Rarity.RARE
	type = Type.Future
	turretID = TurretID.ENERGIZER_TURRET
	turretName = TurretManager.getTurretStat(turretID, "name")
	price = TurretManager.getTurretStat(turretID, "price")
	maxHealth = TurretManager.getTurretStat(turretID, "health")
	baseAttackRange = TurretManager.getTurretStat(turretID, "range")
	armor = TurretManager.getTurretStat(turretID, "armor")
	scaleFactor = TurretManager.getTurretStat(turretID, "scaleFactor")
	baseBuildTime = TurretManager.getTurretStat(turretID, "contructionTime")
	maxTurretsEnergized = TurretManager.getTurretStat(turretID, "maxTurretsEnergized")
	energizeTime = TurretManager.getTurretStat(turretID, "energizeTime")
	energizerDamageBuff = TurretManager.getTurretStat(turretID, "energizerDamageBuff")
	energizerProjctileSpeedBuff = TurretManager.getTurretStat(turretID, "energizerProjectileSpeedBuff")
	energizerAttackRangeBuff = TurretManager.getTurretStat(turretID, "energizerAttackRangeBuff")
	energizerReloadTimeBuff = TurretManager.getTurretStat(turretID, "energizerReloadTimeBuff")

	level = 1
	upgradeTier = 0

	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	bodyCollisionShape = $CollisionShape2D
	energizeTimer = $EnergizeTimer
	rangeArea = $RangeArea
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d, attackRange)
	rangeCollisionShape.shape.radius = attackRange
	baseHealth = maxHealth
	health = maxHealth
	energizeTimer.wait_time = energizeTime

	applyUpgrade()
	isPlaced = true

	# Defer the first scan instead of waiting for _process
	call_deferred("scanCurrentTurretsInRange")

func _process(delta: float) -> void:
	# Removed scanTurretsFirstTime check — handled in _ready via call_deferred
	if not energizeReady or not isPlaced or turretsInRange.is_empty():
		return

	energizeReady = false
	for turret in turretsInRange:
		if is_instance_valid(turret) and turret != self and not turret.energized:
			turretsEnergized += 1
			applyEnergizerBuffsToTurret(turret)
			break

func _on_range_area_body_entered(body: Node2D) -> void:
	if not isPlaced or not body.is_in_group("Turret"):
		return
	if not turretsInRange.has(body):
		turretsInRange.append(body)
	if energizeTimer.is_stopped():
		energizeTimer.start(energizeTime)

func _on_range_area_body_exited(body: Node2D) -> void:
	if isPlaced:
		turretsInRange.erase(body)
		# If a turret left range, free up its energize slot
		if turretsEnergized > 0:
			turretsEnergized -= 1

func applyEnergizerBuffsToTurret(turret):
	if not is_instance_valid(turret) or turret.energized:
		return
	turret.turretProviders["energized"] = self
	turret.energized = true
	ParticleManager.playEnergizedParticle(turret)
	if turret.get("damage") != null:
		turret.damage += ceil(energizerDamageBuff * turret.baseDamage)
	if turret.get("projectileSpeed") != null:
		turret.projectileSpeed += ceil(energizerProjctileSpeedBuff * turret.baseProjectileSpeed)
	if turret.get("attackRange") != null:
		turret.attackRange += ceil(energizerAttackRangeBuff * turret.baseAttackRange)
		turret.line2d = TurretManager.draw_range_circle(turret.line2d, turret.attackRange)
		turret.rangeCollisionShape.shape.radius = turret.attackRange
	if turret.get("reloadTime") != null:
		turret.reloadTime -= round_to_dec(energizerReloadTimeBuff * turret.baseReloadTime, 2)
		if turret.get("reloadTimer") != null:
			turret.reloadTimer.wait_time = turret.reloadTime
	refreshUI(turret)

func removeEnergizerBuffsToTurret(turret: Turret):
	if is_instance_valid(turret) and turret.energized:
		turret.removeEnergized(self)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func scanCurrentTurretsInRange():
	turretsInRange.clear()
	for area in rangeArea.get_overlapping_areas():
		var parent = area.get_parent()
		if parent.is_in_group("Turret") and area.name.contains("SelectArea") and parent != self:
			turretsInRange.append(parent)
	energizeTimer.start()

func _on_energize_time_timeout() -> void:
	if turretsEnergized < maxTurretsEnergized:
		# Only rescan if we need more targets, not every timeout
		_clean_turrets_array()
		energizeReady = true

func _clean_turrets_array():
	turretsInRange = turretsInRange.filter(func(t): return is_instance_valid(t))

func checkAllTurretsEnergized():
	for turret in turretsInRange:
		if is_instance_valid(turret) and not turret.energized:
			return false
	return true

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	if upgradeTier == 0:
		return
	attackRange = baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier)
	maxHealth = baseHealth + (baseHealth * scaleFactor * upgradeTier)
	health = maxHealth
	energizeTime = max(1, energizeTime - scaleFactor)
	energizeTimer.wait_time = energizeTime
	energizerDamageBuff += scaleFactor
	energizerProjctileSpeedBuff += scaleFactor
	energizerAttackRangeBuff += scaleFactor
	energizerReloadTimeBuff += scaleFactor
	for turret in turretsInRange:
		if is_instance_valid(turret) and turret.energized:
			removeEnergizerBuffsToTurret(turret)
			applyEnergizerBuffsToTurret(turret)
	refreshUI(self)

func _on_select_area_mouse_entered() -> void:
	showUI(self)

func _on_select_area_mouse_exited() -> void:
	hideUI()
