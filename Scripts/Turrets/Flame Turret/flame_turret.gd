extends CharacterBody2D

var isPlaced : bool = false
var selected : bool = false
var shooting : bool = false
var isCollisionReady : bool = false

var enemiesInRange = []

var currentParticlesMap = {}

var line2d
var rangeCollisionShape
var rangeIndicator
var topSprite
var selectArea
var bodyCollisionShape

#stats
var kills : int = 0

@onready var description = preload("res://Globals/Scene/TurretDescription/FlameTurretDescription.tscn")

var menu

@export var turretName : String = "Flame Turret"
@export var turretType : String = "Elemental"
@export var price : int = 20
@export var maxHealth : float = 20
@export var baseDamage : float = 3
@export var baseAttackRange : float = 90
@export var baseFireDamage : float = 2
@export var baseFireTime : float = 3
@export var upgradeTier : int = 0
@export var armor : int = 0
@export var level : int = 1

var particleVelocity = 200

var damage
var attackRange
var fireDamage
var fireTime

var health : float

var energized : bool = false
var energizerTurret : CharacterBody2D
var beaconBuffActive : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	damage = baseDamage
	health = maxHealth
	fireDamage = baseFireDamage
	fireTime = baseFireTime
	
	
	upgradeTier = GameManager.getUpgradeTier(turretName)
	
	for x in range(upgradeTier):
		applyUpgradeTier()
	
	#scanCurrentEnemiesInRange()
	
func getName():
	return turretName
	
func _process(delta: float) -> void:
	if enemiesInRange.size() > 0 and not shooting:
		shooting = true
		if $DamageTickTimer.is_stopped():
			$DamageTickTimer.start()
	if enemiesInRange.size() <= 0:
		shooting = false
	if shooting and enemiesInRange.size() > 0 and isPlaced:
		var enemy = GameManager.getClosestEnemyFromSprite($".")
		topSprite.look_at(enemy.global_position)
		#topSprite.rotate(PI/2)
		$"TurretTop/Flame Particle".emitting = true
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true
	if not beaconBuffActive:
		BeaconManager.applyBeaconBuffs()
	if not shooting:
		$DamageTickTimer.stop()
		$"TurretTop/Flame Particle".emitting = false
		
func takeDamage(damage):
	
	if armor > 0:
		damage -= damage * .3
		if armor - damage <= 0:
			armor = 0
		else:
			armor -= damage
	else:
		
		if health - damage <= 0:
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

func _on_area_2d_mouse_exited() -> void:
	pass # Replace with function body.

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)


func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)


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
	baseDamage +=  ceil(baseDamage * GameManager.getUpgradeTierPercent())
	damage = baseDamage
	baseAttackRange +=  ceil(baseAttackRange * GameManager.getUpgradeTierPercent())
	attackRange = baseAttackRange
	baseFireDamage +=  1
	fireDamage = baseFireDamage
	baseFireTime +=  .5
	fireTime = baseFireTime
	particleVelocity += 10
	$TurretTop/FlameArea.position.x += .4
	$TurretTop/FlameArea/CollisionShape2D.shape.height += .8
	$"TurretTop/Flame Particle".process_material.set("initial_velocity",Vector2(particleVelocity,particleVelocity))
	
	
	if energized:
		if is_instance_valid(energizerTurret):
			energizerTurret.applyEnergizerBuffsToTurret($".")
	beaconBuffActive = false
	
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)


func _on_damage_tick_timer_timeout() -> void:
	if shooting:
		for x in $TurretTop/FlameArea.get_overlapping_areas():
			if x.get_parent().is_in_group("Enemy"):
				x.get_parent().hit.emit(damage,self,x.get_parent())
				EffectManager.applyFireEffect(x.get_parent(),self,fireDamage,fireTime)
		$DamageTickTimer.start()
