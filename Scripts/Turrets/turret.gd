extends CharacterBody2D

class_name Turret

var isPlaced : bool = false
var selected : bool = false
var shotReady : bool = true

enum TurretID {
	NONE,
	ARROW_TURRET,
	SENTRY_TURRET,
	ENERGIZER_TURRET,
	FIREWORK_TURRET,
	FLAME_TURRET,
	GOLD_MINE_TURRET,
	GRAVITY_TURRET,
	MEDIC_TURRET,
	MINI_SENTRY_TURRET,
	RAILGUN_TURRET,
	REAPER_TURRET,
	ROYAL_TURRET,
	SEISMIC_TURRET,
	SPIDER_TURRET,
	VOODOO_TURRET,
	TESLA_TURRET,
	ZOMBIE_TURRET,
	BUBBLE_TURRET,
	BOOMERANG_TURRET
}

#signal hit(damage,turret)
#signal upgrade(turret)

var enemiesInRange = []

var effects : Dictionary = {}

var currentParticlesMap = {}

var line2d
var reloadTimer
var rangeCollisionShape
var rangeIndicator
var topSprite : AnimatedSprite2D
var selectArea
var bodyCollisionShape
var rangeArea
var selectAreaCollisionShape

var projectile

var menu

enum Rarity { COMMON, RARE, SUPER_RARE, LEGENDARY, UNSEEN}
var rarity : Rarity
enum Type {Midieval, Modern, Future, Elemental, Armory, Dark, Biological, Magic, Idk}
var type : Type
var turretID : TurretID

var scaleFactor : float

var turretName : String = "None"
@export var price : int = 20
@export var maxHealth : float = 20
@export var baseHealth : float = 10
@export var baseDamage : float = 20
@export var baseProjectileSpeed : float = 400
@export var baseAttackRange : float = 200
@export var baseReloadTime : float = 3.5
@export var upgradeTier : int = 0
@export var armor : int = 0
@export var level : int = 1
@export var baseBuildTime : float = 5

var damage
var projectileSpeed
var attackRange
var reloadTime
var buildTime

var health : float

var energized : bool = false
var hasBubble : bool = false
var beaconBuffActive : bool = false

var turretProviders : Dictionary = {}

var currentBubbleHealth : float

func _process(_delta: float) -> void:
	get_tree().call_group("Turret", "attack")

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		hideUI()

func showRange():
	line2d.show()

func hideRange():
	line2d.hide()

func getName():
	return turretName

func getCost():
	return price

func refreshUI(turretInstance):
	if turretInstance.rangeIndicator.visible:
		var bottomUI = get_tree().current_scene
		if bottomUI != null:
			if bottomUI.has_node("TowerDefenseCanvas"):
				bottomUI = bottomUI.find_child("TowerDefenseCanvas")
			bottomUI.refreshTurretUI(turretInstance)

var hideTimer: SceneTreeTimer = null

func showUI(turretInstance):
	rangeIndicator.show()
	# display UI if we can
	hideTimer = get_tree().create_timer(0.05)
	hideTimer.timeout.connect(func():
		hideTimer = null
		var bottomUI = get_tree().current_scene
		if bottomUI != null:
			if bottomUI.has_node("TowerDefenseCanvas"):
				bottomUI = bottomUI.find_child("TowerDefenseCanvas")
			bottomUI.refreshTurretUI(turretInstance)
	)

func hideUI():
	rangeIndicator.hide()
	if hideTimer != null:
		hideTimer = null
	if get_tree() != null:
		var bottomUI = get_tree().current_scene
		if bottomUI != null:
			if bottomUI.has_node("TowerDefenseCanvas"):
				bottomUI = bottomUI.find_child("TowerDefenseCanvas")
			bottomUI.removeTurretUI()
		
func removeEnergized(turretApplier):
	energized = false
	if currentParticlesMap.has("Energized"):
		currentParticlesMap.get("Energized").queue_free()
		currentParticlesMap.erase("Energized")
	if damage != null:
		damage -= ceil(turretApplier.energizerDamageBuff * baseDamage)
	if projectileSpeed != null:
		projectileSpeed -= ceil(turretApplier.energizerProjctileSpeedBuff * baseProjectileSpeed)
	if attackRange != null:
		attackRange -= ceil(turretApplier.energizerAttackRangeBuff * baseAttackRange)
		line2d = TurretManager.draw_range_circle(line2d, attackRange)
		rangeCollisionShape.shape.radius = attackRange
	if reloadTime != null:
		reloadTime += turretApplier.energizerReloadTimeBuff * baseReloadTime
		reloadTimer.wait_time = reloadTime
	turretProviders.get("energized").turretsEnergized -= 1
	turretProviders.erase("energized")

func removeBubble():
	if currentParticlesMap.has("Bubble"):
		currentParticlesMap.get("Bubble").queue_free()
		currentParticlesMap.erase("Bubble")
	turretProviders.get("bubble").currentBubblesGiven -= 1
	turretProviders.erase("bubble")
	hasBubble = false

func recieveBubble(bubbleHealth : float, turretApplier):
	hasBubble = true
	turretProviders["bubble"] = turretApplier 
	ParticleManager.playBubbleParticle(self)
	currentBubbleHealth = bubbleHealth

func summonEnergizeExplosion():
	var fxData = {}
	var expDmg = TurretManager.getTurretStat(Turret.TurretID.ENERGIZER_TURRET,"explosionDamage")
	var expRange = TurretManager.getTurretStat(Turret.TurretID.ENERGIZER_TURRET,"explosionRange")
	fxData["explosionDamage"] = expDmg
	fxData["explosionRadius"] = expRange
	ExplosionManager.summonExplosion(turretProviders.get("energized"),self.global_position,fxData)

func death():
	print("called")
	for key in turretProviders:
		print(key)
		match key:
			"energized":
				if is_instance_valid(turretProviders.get("energized")):
					if turretProviders.get("energized").level >= 3:
						summonEnergizeExplosion()
					if turretProviders.get("energized").turretsEnergized -1 > 0:
						turretProviders.get("energized").turretsEnergized -= 1
					turretProviders.erase("energized")
			"bubble":
				removeBubble()
	queue_free()
