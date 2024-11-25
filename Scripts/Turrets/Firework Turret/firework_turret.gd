extends CharacterBody2D

var isPlaced : bool = false
var selected : bool = false
var shotReady : bool = true
var isCollisionReady : bool = false
var reloading : bool = false

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


@onready var projectile = preload("res://Projectile Scenes/firework.tscn")
@onready var description = preload("res://Globals/Scene/TurretDescription/ArrowTurretDescription.tscn")

var menu

@export var turretName : String = "Firework Turret"
@export var turretType : String = "Unknown"
@export var price : int = 20
@export var maxHealth : float = 20
@export var baseDamage : float = 20
@export var baseProjectileSpeed : float = 400
@export var baseAttackRange : float = 200
@export var baseReloadTime : float = 1.5
@export var upgradeTier : int = 0
@export var explosionDamage : float = 10
@export var explosionRadius : float = 300
@export var armor : int = 0
@export var level : int = 1

var damage
var projectileSpeed
var attackRange
var reloadTime
var shots = 3

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
	reloadTime = baseReloadTime
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
		shotReady = false
		shoot(GameManager.getClosestEnemyFromSprite($"."))
		await get_tree().create_timer(.5).timeout
		shotReady = true
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true
	if shots <= 0:
		shotReady = false
	if not beaconBuffActive:
		BeaconManager.applyBeaconBuffs()
	
func shoot(enemy):
	if is_instance_valid(enemy) and isPlaced:
		var proj = projectile.instantiate()
		proj.position = position
		proj.linear_velocity = (enemy.position - position).normalized() * projectileSpeed
		
		var dif = self.global_position.angle_to_point(enemy.global_position)
		
		proj.rotation = proj.rotation + dif
		proj.damage = damage
		proj.shooter = self
		proj.explosionDmg = explosionDamage
		proj.explosionSize = explosionRadius
		proj.shotNumber = shots
		get_parent().add_child(proj)
		
		shots -= 1
		if shots == 0:
			topSprite.frame = 3
		if shots == 1:
			topSprite.frame = 2
		if shots == 2:
			topSprite.frame = 1
		

		if shots == 0:
			reloadAnimation()
		
		#dif = topSprite.global_position.angle_to_point(enemy.global_position)
		topSprite.look_at(enemy.global_position)
		topSprite.rotate(PI/2)

func reloadAnimation():
	if not reloading:
		while shots < 3:
			reloading = true
			await get_tree().create_timer((reloadTime)).timeout
			shots += 1
			shotReady = true
			if shots == 1:
				topSprite.frame = 2
			if shots == 2:
				topSprite.frame = 1
			if shots == 3:
				topSprite.frame = 0
			if enemiesInRange.size() > 0:
				reloading = false
				return
			reloading = false

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
	if enemiesInRange.size() <= 0 and shots < 3:
		reloadAnimation()


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

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
