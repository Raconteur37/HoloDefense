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

#stats
var kills : int = 0


@onready var projectile = preload("res://Projectile Scenes/poisondart.tscn")

var menu

enum Rarity {Common}
enum Type {Biological}

const turretName : String = "Spider Turret"
@export var price : int = 10
@export var maxHealth : float = 15
@export var baseDamage : float = 5
@export var baseProjectileSpeed : float = 600
@export var baseAttackRange : float = 200
@export var baseReloadTime : float = 2.25
@export var basePoisonChance : float = 99
@export var basePoisonDuration : float = 3
@export var basePoisonDamage : float = .5
@export var upgradeTier : int = 0
@export var armor : int = 0
@export var level : int = 1
@export var baseBuildTime : float = 4

var damage
var projectileSpeed
var attackRange
var reloadTime
var poisonDamage
var poisonDuration
var poisonChance

var health : float

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
	attackRange = baseAttackRange
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth
	poisonChance = basePoisonChance
	poisonDamage = basePoisonDamage
	poisonDuration = basePoisonDuration

	hit.connect(EntityManager.entityTakeDamage)
	upgrade.connect(EntityManager.applyUpgradeTier)

	upgradeTier = EntityManager.getUpgradeTier(turretName)

	for x in range(upgradeTier):
		upgrade.emit(self)

	if DeveloperMode.inDevMode:
		isPlaced = true
		GameManager.addTurretToDict(self)
		health = 9999


func getName():
	return turretName

func _process(delta: float) -> void:
	if shotReady and enemiesInRange.size() > 0 and isPlaced:
		shoot(EntityManager.getClosestEnemyFromSprite($"."))
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true
	if not beaconBuffActive:
		BeaconManager.applyBeaconBuffs()

func shoot(enemy):
	shotReady = false
	if is_instance_valid(enemy) and isPlaced:
		var proj = projectile.instantiate()
		proj.position = position
		proj.linear_velocity = (enemy.global_position - global_position).normalized() * projectileSpeed

		var dif = self.global_position.angle_to_point(enemy.global_position)

		proj.rotation = proj.rotation + dif
		proj.damage = damage
		proj.shooter = self

		proj.poisonChance = poisonChance
		proj.poisonDamage = poisonDamage
		proj.poisonTime = poisonDuration


		get_parent().add_child(proj)

		reloadTimer.start()
		reloadAnimation()

		#dif = topSprite.global_position.angle_to_point(enemy.global_position)
		topSprite.look_at(enemy.global_position)
		topSprite.rotate(PI/2)

func reloadAnimation():

	var frames : int = 6

	for x in range(frames):

		match x:
			0:
				topSprite.frame = 1
			1:
				topSprite.frame = 2
			2:
				topSprite.frame = 3
			3:
				topSprite.frame = 4
			4:
				topSprite.frame = 5
			5:
				topSprite.frame = 6
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
