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
var shootTimer : Timer
var particle

#stats
var kills : int = 0

@onready var projectile = preload("res://Projectile Scenes/sentry bullet.tscn")

var menu

enum Rarity {Common}
enum Type {Modern}

const turretName : String = "Automated Sentry Turret"
@export var price : int = 20
@export var maxHealth : float = 20
@export var baseDamage : float = 20
@export var baseProjectileSpeed : float = 400
@export var baseAttackRange : float = 200
@export var baseReloadTime : float = 3.5
@export var upgradeTier : int = 0
@export var armor : int = 0
@export var level : int = 1
@export var baseBuildTime : float = 5
@export var maxBullets : int = 150 # Bullets shot before needing to reload
@export var shotTime : float = .1 # The interval of which each bullet will be shot

var damage
var projectileSpeed
var attackRange
var reloadTime
var buildTime

var currentBullets

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
	shootTimer = $ShootTimer
	particle = $TurretTop/AutomatedSentryTurretFire
	shootTimer.wait_time = shotTime
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth
	currentBullets = maxBullets

	hit.connect(EntityManager.entityTakeDamage)
	upgrade.connect(EntityManager.applyUpgradeTier)

	upgradeTier = EntityManager.getUpgradeTier(turretName)

	for x in range(upgradeTier):
		upgrade.emit(self)

	# Check if in devmode durring runtime
	if DeveloperMode.inDevMode:
		isPlaced = true
		GameManager.addTurretToDict(self)
		health = 9999


func getName():
	return turretName

func _process(delta: float) -> void:
	if shotReady and enemiesInRange.size() > 0 and isPlaced and currentBullets > 0 and shootTimer.is_stopped():
		shoot(EntityManager.getClosestEnemyFromSprite($"."))
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true
	if not beaconBuffActive:
		BeaconManager.applyBeaconBuffs()

func shoot(enemy):
	if is_instance_valid(enemy) and isPlaced:

		var animInstance = currentBullets % 4

		currentBullets -= 1

		var proj = projectile.instantiate()
		proj.position = position
		proj.linear_velocity = (enemy.global_position - global_position).normalized() * projectileSpeed
		proj.linear_velocity = proj.linear_velocity + Vector2(randf_range(-100,100),randf_range(-100, 100))

		var dif = self.global_position.angle_to_point(enemy.global_position)

		proj.rotation = proj.rotation + dif
		proj.damage = damage
		proj.shooter = self
		get_parent().add_child(proj)

		#dif = topSprite.global_position.angle_to_point(enemy.global_position)
		topSprite.look_at(enemy.global_position)
		topSprite.rotate(PI/2)

		match animInstance:
			0:
				topSprite.frame = 1
				particle.position.x = 0
			1:
				topSprite.frame = 2
				particle.position.x += 9
			2:
				topSprite.frame = 3
				particle.position.x -= 18
			3:
				topSprite.frame = 4
				particle.position.x += 9

		particle.emitting = true

		if currentBullets <= 0:
			reloadTimer.start()
			reloadAnimation()

		shootTimer.start()

func reloadAnimation():

	shotReady = false

	topSprite.frame = 0

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
	currentBullets = maxBullets

func getCost():
	return price
