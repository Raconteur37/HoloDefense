extends Turret

class_name MedicTurret

var turretsInRange = []

var scanTurretsFirstTime : bool = false

var healReady : bool = true

var healingPulseTimer

var particle : CPUParticles2D

@export var healingTime : int = 5 # How long it takes before each healing pulse
@export var healingAmount : float = 4

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rarity = Rarity.RARE
	type = Type.Future

	turretName = "Medic Turret"
	price = 45
	maxHealth = 45
	baseAttackRange = 100
	upgradeTier = 0
	armor = 0
	level = 1
	baseBuildTime = 15
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
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange + 5)
	rangeCollisionShape.shape.radius = attackRange
	health = maxHealth

	healingPulseTimer.wait_time = healingTime

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
		var turret = load("res://Turret Scenes/Arrow Turret.tscn")
		turret = turret.instantiate()
		turret.global_position = to_local(global_position)
		turret.global_position.x += 100
		turret.global_position.y -= 45
		add_child(turret)

func _process(delta: float) -> void:
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true
	if not beaconBuffActive:
		BeaconManager.applyBeaconBuffs()
	if isPlaced and not scanTurretsFirstTime:
		scanTurretsFirstTime = true
		scanCurrentTurretsInRange()
	if healReady and isPlaced and turretsInRange.size() > 0:
		healTurrets()
		healReady = false
		healingPulseTimer.start()
	if topSprite.frame == 9:
		particle.emitting = true
		topSprite.stop()


func _on_range_area_body_entered(body: Node2D) -> void:
	if isPlaced:
		if body.is_in_group("Turret"):
			turretsInRange.append(body)


func _on_range_area_body_exited(body: Node2D) -> void:
	if isPlaced:
		turretsInRange.erase(body)

func healTurrets():
	topSprite.play("Heal")
	for turret in turretsInRange:
		if is_instance_valid(turret):
			if turret.health < turret.maxHealth:
				EntityManager.healTurret(turret,healingAmount)
		else:
			turretsInRange.erase(turret)


func scanCurrentTurretsInRange():
	print("got hererere")
	for entity in $RangeArea.get_overlapping_bodies():
		print(entity)
	healingPulseTimer.start()


func _on_healing_pulse_timer_timeout() -> void:
	if turretsInRange.size() == 0:
		scanCurrentTurretsInRange()
	if not healReady:
		healReady = true
