extends CharacterBody2D

var isPlaced : bool = false
var selected : bool = false
var shooting : bool = false
var isCollisionReady : bool = false

signal hit(damage,turret)
signal upgrade(turret)

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

enum Rarity {Rare}
enum Type {Elemental}

const turretName : String = "Flame Turret"
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
	
	hit.connect(EntityManager.entityTakeDamage)
	upgrade.connect(EntityManager.applyUpgradeTier)
	
	upgradeTier = EntityManager.getUpgradeTier(turretName)
	
	for x in range(upgradeTier):
		upgrade.emit(self)
	
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
		var enemy = EntityManager.getClosestEnemyFromSprite($".")
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

func getCost():
	return price

func _on_damage_tick_timer_timeout() -> void:
	if shooting:
		for x in $TurretTop/FlameArea.get_overlapping_areas():
			if x.get_parent().is_in_group("Enemy"):
				x.get_parent().hit.emit(damage,self,x.get_parent())
				EffectManager.applyFireEffect(x.get_parent(),self,fireDamage,fireTime)
		$DamageTickTimer.start()
