extends CharacterBody2D

var isPlaced : bool = false
var selected : bool = false
var shotReady : bool = true
var isCollisionReady : bool = false

var enemiesInRange = []

var currentParticlesMap = {}

var line2d
var summonTimer
var rangeCollisionShape
var rangeIndicator
var topSprite
var selectArea
var bodyCollisionShape

#stats
var kills : int = 0

var currentMinions = []

@onready var knightMinion = preload("res://Minion Scenes/Knight Minion.tscn")
@onready var description = preload("res://Globals/Scene/TurretDescription/RoyalTurretDescription.tscn")

var menu

@export var turretName : String = "Royal Turret"
@export var turretType : String = "Medieval"
@export var price : int = 80
@export var maxHealth : float = 20
@export var baseAttackRange : float = 200
@export var baseSummonTime : float = 5
@export var upgradeTier : int = 0
@export var armor : int = 50
@export var level : int = 1

@export var maxKnights : int = 3
@export var knightHealth : float  = 30
@export var knightDamage : float = 10

var currentKnightAmount : int = 0

var attackRange
var summonTime

var health : float

var energized : bool = false
var energizerTurret : CharacterBody2D
var beaconBuffActive : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	summonTimer = $SummonTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	attackRange = baseAttackRange
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	summonTime = baseSummonTime
	summonTimer.wait_time = baseSummonTime
	health = maxHealth
	
	upgradeTier = GameManager.getUpgradeTier(turretName)
	
	for x in range(upgradeTier):
		applyUpgradeTier()
	
	#scanCurrentEnemiesInRange()
	
func getName():
	return turretName
	
func _process(delta: float) -> void:
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true
		summonTimer.start()
	if not beaconBuffActive:
		BeaconManager.applyBeaconBuffs()
	
func summonMinion():
	if currentKnightAmount < maxKnights:
		var knight = knightMinion.instantiate()
		knight.health = knightHealth
		knight.damage = knightDamage
		knight.turretOwner = self
		
		knight.position = position
		knight.velocity = Vector2(randi_range(-1,1),randi_range(-1,1)).normalized() * 500
		
		currentMinions.append(knight)
		
		currentKnightAmount += 1
		
		get_parent().add_child(knight)


func takeDamage(damage):
	
	if armor > 0:
		damage -= damage * .3
		if armor - damage <= 0:
			armor = 0
		else:
			armor -= damage
	else:
		if health - damage <= 0:
			for x in currentMinions:
				x.queue_free()
			GameManager.removeTurretFromGame(self)
		else:
			health = health - damage

func openSelectedMenu():
	if isPlaced:
		menu = description.instantiate()
		menu.applyTurret(self)
		get_parent().add_child(menu)
		showRange()
	
func closeSelectMenu():
	if is_instance_valid(menu):
		menu.close()
	hideRange()
	
func addKill():
	kills += 1

func showRange():
	line2d.show()
	
func hideRange():
	line2d.hide()

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)


func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)


func _on_reload_timer_timeout() -> void:
	shotReady = true

func getCost():
	return price

func _on_select_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and isPlaced:
		if body.attackReady:
			takeDamage(body.damage)
			body.attackReady = false
			body.attackTimer.start()

func applyUpgradeTier():
	maxHealth += ceil(maxHealth * GameManager.getUpgradeTierPercent())
	health = maxHealth
	knightDamage +=  ceil(knightDamage * GameManager.getUpgradeTierPercent())
	knightHealth += ceil(knightHealth * GameManager.getUpgradeTierPercent())
	baseAttackRange +=  ceil(baseAttackRange * GameManager.getUpgradeTierPercent())
	attackRange = baseAttackRange
	summonTime -=  round_to_dec(summonTime * GameManager.getUpgradeTierPercent(),2)
	
	if energized:
		if is_instance_valid(energizerTurret):
			energizerTurret.applyEnergizerBuffsToTurret($".")
	beaconBuffActive = false
	
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	summonTimer.wait_time = summonTime

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func isEnemyTargeted(enemy):
	for x in currentMinions:
		if x.enemy == enemy:
			return true

func removeMinion(minion):
	currentMinions.erase(minion)
	if minion.getName().find("Knight") > -1:
		currentKnightAmount -= 1
	minion.queue_free()

func _on_summon_timer_timeout() -> void:
	summonMinion()
