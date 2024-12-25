extends CharacterBody2D

var isPlaced : bool = false
var selected : bool = false
var shotReady : bool = true
var isCollisionReady : bool = false

signal hit(damage,turret)
signal upgrade(turret)

var enemiesInRange = []

var currentParticlesMap = {}

var line2d
var reloadTimer
var rangeCollisionShape
var rangeIndicator
var topSprite
var selectArea
var bodyCollisionShape

var frameOne = false

#stats
var kills : int = 0


@onready var projectile = preload("res://Particle Scenes/Turrets/Tesla Turret/Electricity Shoot.tscn")

var menu

enum Rarity {SuperRare}
enum Type {Elemental}

const turretName : String = "Tesla Turret"
@export var price : int = 50
@export var maxHealth : float = 60
@export var baseDamage : float = 9
@export var baseAttackRange : float = 200
@export var baseReloadTime : float = 5
@export var baseDamageTickTime : float = .5
@export var baseAttackingTime : float = 5
@export var upgradeTier : int = 0
@export var armor : int = 20
@export var level : int = 1
@export var baseBuildTime : float = 1

var damage
var attackRange
var reloadTime
var buildTime

var health : float
var shooting : bool

var energized : bool = false
var energizerTurret : CharacterBody2D
var beaconBuffActive : bool = false


func _ready() -> void:
	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	health = maxHealth
	
	hit.connect(EntityManager.entityTakeDamage)
	upgrade.connect(EntityManager.applyUpgradeTier)
	
	upgradeTier = EntityManager.getUpgradeTier(turretName)
	
	for x in range(upgradeTier):
		upgrade.emit(self)
		
func getName():
	return turretName
	
func _process(delta: float) -> void:
	if enemiesInRange.size() > 0 and not shooting and attackingTimer.is_stopped() and shotReady and isPlaced:
		topSprite.animation = "Attacking"
		electricityParticle.emitting = true
		shooting = true
		attackingTimer.start()
		if damageTickTimer.is_stopped():
			damageTickTimer.start()
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true
	if not beaconBuffActive:
		BeaconManager.applyBeaconBuffs()
	if not shooting:
		damageTickTimer.stop()

func reloadAnimation():
	
	attackingTimer.stop()
	
	reloadTimer.start()
	
	topSprite.animation = "Ready"
	
	var frames : int = 4

	for x in range(frames):
		match x:
			0:
				topSprite.frame = 0
			1:
				topSprite.frame = 1
			2:
				topSprite.frame = 2
			3:
				topSprite.frame = 3
		await get_tree().create_timer((reloadTime / frames)).timeout
	

func openSelectedMenu():
	if isPlaced:
		var description = load("res://Globals/Scene/TurretDescription/TurretDescriptionScene.tscn")
		menu = description.instantiate()
		get_parent().add_child(menu)
		menu.buildContainer(self)
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

func _on_damage_tick_timer_timeout() -> void:
	if shooting:
		for x in $RangeArea.get_overlapping_areas():
			if x.get_parent().is_in_group("Enemy"):
				var shockParticle = projectile.instantiate()
				shockParticle.global_position = global_position

				# Set the positions
				var start_position = Vector2(0,0)
				var end_position = to_local(x.get_parent().global_position)
				var points = [start_position,end_position]

				shockParticle.points = points

				# Add to the scene
				get_parent().add_child(shockParticle)
				
				x.get_parent().hit.emit(damage,self,x.get_parent(),self) # Fix damage type
		damageTickTimer.start()
	else:
		damageTickTimer.stop()

func _on_attacking_timer_timeout() -> void:
	electricityParticle.emitting = false
	shooting = false
	shotReady = false
	reloadAnimation()
