extends CharacterBody2D

var isPlaced : bool = false
var selected : bool = false
var shotReady : bool = true
var isCollisionReady : bool = false

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


@onready var projectile = preload("res://Projectile Scenes/railgunbullet.tscn")
@onready var description = preload("res://Globals/Scene/TurretDescription/ArrowTurretDescription.tscn")

var menu

@export var turretName : String = "Railgun Turret"
@export var turretType : String = "Heavy Weapons"
@export var price : int = 35
@export var maxHealth : float = 50
@export var baseDamage : float = 100
@export var baseProjectileSpeed : float = 1000
@export var baseAttackRange : float = 500
@export var baseReloadTime : float = 10.0
@export var upgradeTier : int = 0
@export var armor : int = 30
@export var level : int = 1
@export var pierce : int = 1

var damage
var projectileSpeed
var attackRange
var reloadTime

var health : float

var energized : bool = false
var energizerTurret : CharacterBody2D
var beaconBuffActive : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $ArrowTurretTop
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
	
	
	upgradeTier = GameManager.getUpgradeTier(turretName)
	
	for x in range(upgradeTier):
		applyUpgradeTier()
	
	#scanCurrentEnemiesInRange()
	
func getName():
	return turretName
	
func _process(delta: float) -> void:
	if shotReady and enemiesInRange.size() > 0 and isPlaced:
		shoot(GameManager.getClosestEnemyFromSprite($"."))
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
		proj.linear_velocity = (enemy.position - position).normalized() * projectileSpeed
		
		var dif = self.global_position.angle_to_point(enemy.global_position)
		
		proj.rotation = proj.rotation + dif
		proj.damage = damage
		proj.shooter = self
		get_parent().add_child(proj)
		
		reloadTimer.start()
		reloadAnimation()
		
		#dif = topSprite.global_position.angle_to_point(enemy.global_position)
		topSprite.look_at(enemy.global_position)
		topSprite.rotate(PI/2)

func reloadAnimation():
	for x in range(10):
		if x == 0:
			topSprite.frame = 1
		if x == 1:
			topSprite.frame = 2
		if x == 2:
			topSprite.frame = 3
		if x == 3:
			topSprite.frame = 4
		if x == 4:
			topSprite.frame = 5
		if x == 5:
			topSprite.frame = 6
		if x == 6:
			topSprite.frame = 7
		if x == 7:
			topSprite.frame = 8
		if x == 8:
			topSprite.frame = 9
		if x == 9:
			topSprite.frame = 10
		if x == 10:
			topSprite.frame = 0
		await get_tree().create_timer((reloadTime / 10)).timeout
		
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
	baseDamage +=  ceil(baseDamage * GameManager.getUpgradeTierPercent())
	damage = baseDamage
	baseProjectileSpeed +=  ceil(baseProjectileSpeed * GameManager.getUpgradeTierPercent())
	projectileSpeed = baseProjectileSpeed
	baseAttackRange +=  ceil(baseAttackRange * GameManager.getUpgradeTierPercent())
	attackRange = baseAttackRange
	baseReloadTime -=  round_to_dec(baseReloadTime * GameManager.getUpgradeTierPercent(),2)
	reloadTime = baseReloadTime
	
	if energized:
		if is_instance_valid(energizerTurret):
			energizerTurret.applyEnergizerBuffsToTurret($".")
	beaconBuffActive = false
	
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTimer.wait_time =  reloadTime

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
