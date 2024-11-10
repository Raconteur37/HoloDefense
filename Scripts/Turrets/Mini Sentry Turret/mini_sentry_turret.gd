extends CharacterBody2D

var isPlaced : bool = false
var selected : bool = false
var shotReady : bool = true
var isCollisionReady : bool = false

var enemiesInRange = []

var line2d
var reloadTimer
var rangeCollisionShape
var rangeIndicator
var topSprite
var bodyCollisionShape

#stats
var kills : int = 0


@onready var projectile = preload("res://Projectile Scenes/sentry bullet.tscn") # TODO CHANGE PER TURRET
@onready var description = preload("res://Globals/Scene/TurretDescription/MiniSentryTurretDescription.tscn") # TODO CHANGE PER TURRET

var menu

@export var turretName : String = "Mini Sentry Turret"
@export var turretType : String = "Mechanical"
@export var price : int = 30
@export var maxHealth : float = 25
@export var damage : float = 7
@export var projectileSpeed : float = 500
@export var attackRange : float = 100
@export var reloadTime : float = .5
@export var upgradeTier : int = 0
@export var armor : int = 30
@export var level : int = 1

var health : float

var energized : bool = false
var beaconBuffActive : bool = false

var energizerDamageBuff : float = 0.0
var energizerRangeBuff : float = 0.0
var energizerProjctileSpeedBuff : float = 0.0
var energizerAttackRangeBuff : float = 0.0
var energizerReloadTimeBuff : float = 0.0

var beaconDamageBuff : float = 0.0
var beaconHealthBuff : float = 0.0
var beaconProjectileSpeedBuff : float = 0.0
var beaconAttackRangeBuff : float = 0.0
var beaconReloadTimeBuff : float = 0.0

var moneyBonus : float = 0.0
var xpBonus : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $MiniSentryTurretTop # TODO CHANGE PER TURRET
	bodyCollisionShape = $CollisionShape2D
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTimer.wait_time = reloadTime
	health = maxHealth
	
	upgradeTier = GameManager.getUpgradeTier(turretName)
	
	for x in range(upgradeTier):
		applyUpgradeTier()
	
func _process(delta: float) -> void:
	if shotReady and enemiesInRange.size() > 0 and isPlaced:
		shoot(GameManager.getClosestEnemyFromSprite($"."))
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true

func reloadAnimation():
	var reloadFrames : int = 2
	for x in range(reloadFrames):
		if x == 0:
			topSprite.frame = 1
		if x == 1:
			topSprite.frame = 0
		await get_tree().create_timer((reloadTime / reloadFrames)).timeout


func openSelectedMenu(): # TODO CHANGE PER TURRET
	if isPlaced:
		menu = description.instantiate()
		menu.applyTurret(self)
		get_parent().add_child(menu)
		showRange()

########################################################### Stays the same

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
		
		topSprite.look_at(enemy.global_position)
		topSprite.rotate(PI/2)


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

func closeSelectMenu():
	if is_instance_valid(menu):
		menu.close()
	hideRange()
	
func _on_area_2d_mouse_entered() -> void:
	if isPlaced:
		openSelectedMenu()

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
	
func getName():
	return turretName

func _on_select_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and isPlaced:
		if body.attackReady:
			takeDamage(body.damage)
			body.attackReady = false
			body.attackTimer.start()
			
func applyUpgradeTier(): # SAME
	maxHealth += round_to_dec((maxHealth * GameManager.getUpgradeTierPercent()),1)
	health = maxHealth
	damage +=  round_to_dec((damage * GameManager.getUpgradeTierPercent()),1)
	projectileSpeed +=  round_to_dec((projectileSpeed * GameManager.getUpgradeTierPercent()),1)
	attackRange +=  round_to_dec((attackRange * GameManager.getUpgradeTierPercent()),1)
	reloadTime -=  round_to_dec((reloadTime * GameManager.getUpgradeTierPercent()),2)
	
	applyEnergizerBuffs()
	applyBeaconBuffs()
	
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTimer.wait_time =  reloadTime

func applyEnergizerBuffs(): # SAME
	if not energized:
		damage +=  round_to_dec((energizerDamageBuff * damage),1)
		projectileSpeed +=  round_to_dec((energizerProjctileSpeedBuff * damage),1)
		attackRange +=  round_to_dec((energizerAttackRangeBuff * attackRange),1)
		reloadTime -=  round_to_dec((energizerReloadTimeBuff * reloadTime),2)
		
		line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
		rangeCollisionShape.shape.radius = attackRange
		reloadTimer.wait_time =  reloadTime
		energized = true
		
func applyBeaconBuffs(): # SAME
	if not beaconBuffActive:
		maxHealth += round_to_dec((beaconHealthBuff * maxHealth),1)
		health = maxHealth
		damage +=  round_to_dec((beaconDamageBuff * damage),1)
		projectileSpeed +=  round_to_dec((beaconProjectileSpeedBuff * damage),1)
		attackRange +=  round_to_dec((beaconAttackRangeBuff * attackRange),1)
		reloadTime -=  round_to_dec((beaconReloadTimeBuff * reloadTime),2)
		
		line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
		rangeCollisionShape.shape.radius = attackRange
		reloadTimer.wait_time =  reloadTime
		beaconBuffActive = true

func round_to_dec(num, digit): # SAME
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
