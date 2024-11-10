extends CharacterBody2D

var isPlaced : bool = false
var selected : bool = false
var isCollisionReady : bool = false
var scanTurretsFirstTime : bool = false

var turretsInRange = []

var line2d
var rangeCollisionShape
var rangeIndicator
var topSprite
var bodyCollisionShape
var energizeTimer

#stats
var turretsEnergized : int = 0


@onready var description = preload("res://Globals/Scene/TurretDescription/EnergizerTurretDescription.tscn") # TODO CHANGE PER TURRET

var menu

@export var turretName : String = "Energizer Turret"
@export var turretType : String = "Support"
@export var price : int = 30
@export var maxHealth : float = 25
@export var attackRange : float = 150
@export var upgradeTier : int = 0
@export var armor : int = 30
@export var level : int = 1

var health : float

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
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $MiniSentryTurretTop # TODO CHANGE PER TURRET
	bodyCollisionShape = $CollisionShape2D
	energizeTimer = $EnergizeTimer
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	health = maxHealth
	
	energizeTimer.wait_time = energizeTime
	upgradeTier = GameManager.getUpgradeTier(turretName)
	
	for x in range(upgradeTier):
		applyUpgradeTier()
	
func _process(delta: float) -> void:
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true
	if not beaconBuffActive:
		applyBeaconBuffs()
	if isPlaced and not scanTurretsFirstTime:
		scanTurretsFirstTime = true
		scanCurrentTurretsInRange()

func openSelectedMenu(): # TODO CHANGE PER TURRET
	if isPlaced:
		menu = description.instantiate()
		menu.applyTurret(self)
		get_parent().add_child(menu)
		showRange()

########################################################### Stays the same


func takeDamage(damage):
	if armor > 0:
		damage -= damage * .3
		if armor - damage <= 0:
			armor = 0
		else:
			armor -= damage
	else:
		
		if health - damage <= 0:
			for x in turretsInRange:
				if is_instance_valid(x):
					if x.energized:
						x.energized = false
			GameManager.removeTurretFromGame(self)
		else:
			health = health - damage

func closeSelectMenu():
	if is_instance_valid(menu):
		menu.close()
	hideRange()
	
func _on_area_2d_mouse_entered() -> void:
	if isPlaced:
		pass
		#openSelectedMenu()

func addTurretBuffed():
	turretsEnergized += 1

func showRange():
	line2d.show()
	
func hideRange():
	line2d.hide()

func _on_area_2d_mouse_exited() -> void:
	pass # Replace with function body.

func _on_range_area_body_entered(body: Node2D) -> void:
	if isPlaced:
		if (body.is_in_group("Turret")) and body != self:
			turretsInRange.append(body)
	if isPlaced:
		if energizeTimer.is_stopped():
			energizeTimer.start()
			

func _on_range_area_body_exited(body: Node2D) -> void:
	if isPlaced:
		turretsInRange.erase(body)

func getCost():
	return price
	
func getName():
	return turretName

func _on_select_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and isPlaced:
		if body.attackReady:
			takeDamage(body.damage)
			body.attackReady = false
			body.attackTimer.start()
			
func applyUpgradeTier(): 
	maxHealth += round_to_dec((maxHealth * GameManager.getUpgradeTierPercent()),1)
	health = maxHealth
	attackRange +=  round_to_dec((attackRange * GameManager.getUpgradeTierPercent()),1)
	
	energized = false
	beaconBuffActive = false
	
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
		
func applyEnergizerBuffsToTurret(turret):
	turret.energized = true
	if turret.get("damage") != null:
		turret.damage +=  round_to_dec((energizerDamageBuff * turret.damage),1)
	if turret.get("projectileSpeed") != null:
		turret.projectileSpeed +=  round_to_dec((energizerProjctileSpeedBuff * turret.projectileSpeed),1)
	if turret.get("attackRange") != null:
		turret.attackRange +=  round_to_dec((energizerAttackRangeBuff * turret.attackRange),1)
		turret.line2d = PlacementManager.draw_range_cirle(turret.line2d,turret.attackRange)
		turret.rangeCollisionShape.shape.radius = turret.attackRange
	if turret.get("reloadTime") != null:
		turret.reloadTime -=  round_to_dec((energizerReloadTimeBuff * turret.reloadTime),1)
		turret.reloadTimer.wait_time = turret.reloadTime

func applyBeaconBuffs(): 
	if not beaconBuffActive:
		maxHealth += round_to_dec((BeaconManager.beaconHealthBuff * maxHealth),1)
		health = maxHealth
		attackRange +=  round_to_dec((BeaconManager.beaconAttackRangeBuff * attackRange),1)
		
		line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
		rangeCollisionShape.shape.radius = attackRange
		beaconBuffActive = true

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
	
# TODO WORK ON MAKING THE UI UPDATE WHILE ITS OPEN
