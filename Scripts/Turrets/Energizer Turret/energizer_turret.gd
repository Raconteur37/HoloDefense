extends CharacterBody2D

var isPlaced : bool = false
var selected : bool = false
var isCollisionReady : bool = false
var scanTurretsFirstTime : bool = false

signal hit(damage,turret)
signal upgrade(turret)

var turretsInRange = []

var currentParticlesMap = {}

var line2d
var rangeCollisionShape
var rangeIndicator
var topSprite
var bodyCollisionShape
var energizeTimer

#stats
var turretsEnergized : int = 0

var menu

enum Rarity {Rare}
enum Type {Support}

const turretName : String = "Energizer Turret"
@export var price : int = 35
@export var maxHealth : float = 20
@export var baseAttackRange : float = 150
@export var upgradeTier : int = 0
@export var armor : int = 0
@export var level : int = 1
@export var baseBuildTime : float = 15

var health : float
var attackRange

var energized : bool = false
var energizerTurret
var beaconBuffActive : bool = false

@export var maxTurretsEnergized : int = 5
@export var energizeTime : float = 5
@export var energizerDamageBuff : float = 0.02
@export var energizerProjctileSpeedBuff : float = 0.02
@export var energizerAttackRangeBuff : float = 0.02
@export var energizerReloadTimeBuff : float = 0.02

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop # TODO CHANGE PER TURRET
	bodyCollisionShape = $CollisionShape2D
	energizeTimer = $EnergizeTimer
	attackRange = baseAttackRange
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange + 5)
	rangeCollisionShape.shape.radius = attackRange
	health = maxHealth
	
	energizeTimer.wait_time = energizeTime
	
	hit.connect(EntityManager.entityTakeDamage)
	upgrade.connect(EntityManager.applyUpgradeTier)
	
	upgradeTier = EntityManager.getUpgradeTier(turretName)
	
	for x in range(upgradeTier):
		upgrade.emit(self)

	if DeveloperMode.inDevMode:
		isPlaced = true
		GameManager.addTurretToDict(self)
		health = 9999
	
func _process(delta: float) -> void:
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true
	if not beaconBuffActive:
		BeaconManager.applyBeaconBuffs()
	if isPlaced and not scanTurretsFirstTime:
		scanTurretsFirstTime = true
		scanCurrentTurretsInRange()

func openSelectedMenu(): # TODO CHANGE PER TURRET
	if isPlaced:
		var description = load("res://Globals/Scene/TurretDescription/TurretDescriptionScene.tscn")
		menu = description.instantiate()
		get_parent().add_child(menu)
		menu.buildContainer(self)
		showRange()

########################################################### Stays the same

func closeSelectMenu():
	if is_instance_valid(menu):
		menu.close()
	hideRange()

func addTurretBuffed():
	turretsEnergized += 1

func showRange():
	line2d.show()
	
func hideRange():
	line2d.hide()

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

func getCost():
	return price
	
func getName():
	return turretName

func applyEnergizerBuffsToTurret(turret):
	if is_instance_valid(turret):
		if not turret.energized:
			turret.energized = true
			ParticleManager.playEnergizedParticle(turret)
		if turret.get("damage") != null:
			turret.damage +=  ceil(energizerDamageBuff * turret.baseDamage)
		if turret.get("projectileSpeed") != null:
			turret.projectileSpeed +=  ceil(energizerProjctileSpeedBuff * turret.baseProjectileSpeed)
		if turret.get("attackRange") != null:
			turret.attackRange +=  ceil(energizerAttackRangeBuff * turret.baseAttackRange)
			turret.line2d = PlacementManager.draw_range_cirle(turret.line2d,turret.attackRange)
			turret.rangeCollisionShape.shape.radius = turret.attackRange
		if turret.get("reloadTime") != null:
			turret.reloadTime -=  round_to_dec(energizerReloadTimeBuff * turret.baseReloadTime,2)
			turret.reloadTimer.wait_time = turret.reloadTime
		
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

func round_to_dec(num, digit): # SAME
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func scanCurrentTurretsInRange():
	for x in $RangeArea.get_overlapping_areas():
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
		if not checkAllTurretsEnergized():
			while true:
				var turret = turretsInRange.pick_random()
				if is_instance_valid(turret):
					if not turret.energized:
						turret.energizerTurret = $"."
						turretsEnergized += 1
						applyEnergizerBuffsToTurret(turret)
						break
				else:
					turretsInRange.erase(turret)
		if not checkAllTurretsEnergized():
			energizeTimer.start()
