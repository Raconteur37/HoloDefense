extends Turret

class_name EnergizerTurret

var scanTurretsFirstTime : bool = false
var energizeReady : bool = false

var turretsInRange = []

var energizeTimer

var turretsEnergized : int = 0

@export var maxTurretsEnergized : int
@export var energizeTime : float
@export var energizerDamageBuff : float
@export var energizerProjctileSpeedBuff : float
@export var energizerAttackRangeBuff : float
@export var energizerReloadTimeBuff : float

func onDeath():
	for turret in turretsInRange:
		if turret.energized:
			removeEnergizerBuffsToTurret(turret)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rarity = Rarity.RARE
	type = Type.Future
	turretID = TurretID.ENERGIZER_TURRET
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"contructionTime")
	maxTurretsEnergized = TurretManager.getTurretStat(turretID,"maxTurretsEnergized")
	energizeTime = TurretManager.getTurretStat(turretID,"energizeTime")
	energizerDamageBuff = TurretManager.getTurretStat(turretID,"energizerDamageBuff")
	energizerProjctileSpeedBuff = TurretManager.getTurretStat(turretID,"energizerProjectileSpeedBuff")
	energizerAttackRangeBuff = TurretManager.getTurretStat(turretID,"energizerAttackRangeBuff")
	energizerReloadTimeBuff = TurretManager.getTurretStat(turretID,"energizerReloadTimeBuff")

	level = 1
	upgradeTier = 0

	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop # TODO CHANGE PER TURRET
	bodyCollisionShape = $CollisionShape2D
	energizeTimer = $EnergizeTimer
	rangeArea = $RangeArea
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	health = maxHealth

	energizeTimer.wait_time = energizeTime

	hit.connect(EntityManager.entityTakeDamage)

	upgradeTier = EntityManager.getUpgradeTier(turretName)

	for x in range(upgradeTier):
		upgrade.emit(self)

	if DeveloperMode.inDevMode:
		isPlaced = true
		GameManager.addTurretToDict(self)
		health = 99
	if GameManager.previewMode:
		var turret = load("res://Turret Scenes/Arrow Turret.tscn")
		turret = turret.instantiate()
		turret.global_position = to_local(global_position)
		turret.global_position.x += 100
		turret.global_position.y -= 45
		add_child(turret)

func _process(delta: float) -> void:
	if isPlaced and not scanTurretsFirstTime:
		scanTurretsFirstTime = true
		scanCurrentTurretsInRange()
	if energizeReady and isPlaced and turretsInRange.size() > 0:
		energizeReady = false
		for turret in turretsInRange:
			if is_instance_valid(turret) and turret != self:
				if not turret.energized:
					turretsEnergized += 1
					applyEnergizerBuffsToTurret(turret)
					break
			else:
				turretsInRange.erase(turret)

func addTurretBuffed():
	turretsEnergized += 1

func _on_range_area_body_entered(body: Node2D) -> void:
	if isPlaced:
		if body.is_in_group("Turret"):
			turretsInRange.append(body)
	if isPlaced:
		if energizeTimer.is_stopped():
			energizeTimer.start(energizeTime)


func _on_range_area_body_exited(body: Node2D) -> void:
	if isPlaced:
		turretsInRange.erase(body)

func applyEnergizerBuffsToTurret(turret):
	if is_instance_valid(turret):
		if not turret.energized:
			turret.energizerTurret = self
			turret.energized = true
			ParticleManager.playEnergizedParticle(turret)
		if turret.get("damage") != null:
			turret.damage +=  ceil(energizerDamageBuff * turret.baseDamage)
		if turret.get("projectileSpeed") != null:
			turret.projectileSpeed +=  ceil(energizerProjctileSpeedBuff * turret.baseProjectileSpeed)
		if turret.get("attackRange") != null:
			turret.attackRange +=  ceil(energizerAttackRangeBuff * turret.baseAttackRange)
			turret.line2d = TurretManager.draw_range_circle(turret.line2d,turret.attackRange)
			turret.rangeCollisionShape.shape.radius = turret.attackRange
		if turret.get("reloadTime") != null:
			turret.reloadTime -=  round_to_dec(energizerReloadTimeBuff * turret.baseReloadTime,2)
			if turret.get("reloadTimer") != null:
				turret.reloadTimer.wait_time = turret.reloadTime
		refreshUI(turret)

func removeEnergizerBuffsToTurret(turret):
	turret.energized = false
	if turret.get("damage") != null:
		turret.damage -=  ceil(energizerDamageBuff * turret.baseDamage)
	if turret.get("projectileSpeed") != null:
		turret.projectileSpeed -=  ceil(energizerProjctileSpeedBuff * turret.baseProjectileSpeed)
	if turret.get("attackRange") != null:
		turret.attackRange -=  ceil(energizerAttackRangeBuff * turret.baseAttackRange)
		turret.line2d = PlacementManager.draw_range_cirle(turret.line2d,turret.attackRange)
		turret.rangeCollisionShape.shape.radius = turret.attackRange
	if turret.get("reloadTime") != null:
		turret.reloadTime +=  round_to_dec(energizerReloadTimeBuff * turret.baseReloadTime,2)
		turret.reloadTimer.wait_time = turret.reloadTime
	refreshUI(turret)

func round_to_dec(num, digit): # SAME
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func scanCurrentTurretsInRange():
	for x in rangeArea.get_overlapping_areas():
		if x.get_parent().is_in_group("Turret") and x.name.contains("SelectArea") and x.get_parent() != self:
			x = x.get_parent()
			turretsInRange.append(x)
	energizeTimer.start()

func checkAllTurretsEnergized():
	for turret in turretsInRange:
		if is_instance_valid(turret):
			if not turret.energized:
				return false
	return true

func _on_energize_time_timeout() -> void:
	if turretsEnergized < maxTurretsEnergized:
		scanCurrentTurretsInRange()
		if not energizeReady:
			energizeReady = true

func _on_select_area_mouse_entered() -> void:
	showUI(self)

func _on_select_area_mouse_exited() -> void:
	hideUI()
