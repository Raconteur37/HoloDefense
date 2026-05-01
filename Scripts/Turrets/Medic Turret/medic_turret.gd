extends Turret

class_name MedicTurret

var turretsInRange = []

var scanTurretsFirstTime : bool = false

var healReady : bool = true

var healingPulseTimer

var particle : CPUParticles2D

@export var healingTime : int # How long it takes before each healing pulse
@export var healingAmount : float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rarity = Rarity.RARE
	type = Type.Future
	turretID = TurretID.MEDIC_TURRET
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	healingTime = TurretManager.getTurretStat(turretID,"healingTime")
	healingAmount = TurretManager.getTurretStat(turretID,"healingAmount")

	upgradeTier = 0
	level = 1

	particle = $HealingPulse
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop # TODO CHANGE PER TURRET
	bodyCollisionShape = $CollisionShape2D
	healingPulseTimer = $HealingPulseTimer
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange + 5)
	rangeCollisionShape.shape.radius = attackRange
	health = maxHealth

	healingPulseTimer.wait_time = healingTime


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
	if healReady and isPlaced and turretsInRange.size() > 0:
		topSprite.play("Heal")
		healReady = false
		healingPulseTimer.start()
	if topSprite.frame == 9:
		healTurrets()
		particle.emitting = true
		topSprite.stop()


func _on_range_area_body_entered(body: Node2D) -> void:
	if isPlaced:
		if body.is_in_group("Turret") and body != self:
			turretsInRange.append(body)


func _on_range_area_body_exited(body: Node2D) -> void:
	if isPlaced:
		turretsInRange.erase(body)

func healTurrets():
	for turret in turretsInRange:
		if is_instance_valid(turret):
			if turret.health < turret.maxHealth:
				EntityManager.healTurret(turret,healingAmount)
		else:
			turretsInRange.erase(turret)


func scanCurrentTurretsInRange():
	for entity in $RangeArea.get_overlapping_areas():
		if entity.get_parent().is_in_group("Turret") and entity.name.contains("SelectArea") and entity.get_parent() != self:
			entity = entity.get_parent()
			turretsInRange.append(entity)
	healingPulseTimer.start()


func _on_healing_pulse_timer_timeout() -> void:
	if turretsInRange.size() == 0:
		scanCurrentTurretsInRange()
	if not healReady:
		healReady = true

func _on_select_area_mouse_entered() -> void:
	showUI(self)

func _on_select_area_mouse_exited() -> void:
	hideUI()
