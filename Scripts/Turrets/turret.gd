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
	BOOMERANG_TURRET,
	SNIPER_TURRET,
	MORTAR_TURRET
}

#signal hit(damage,turret)
#signal upgrade(turret)

var enemiesInRange = []

var effects : Dictionary = {}

var currentParticlesMap : Dictionary = {}

var line2d
var reloadTimer
var rangeCollisionShape
var rangeIndicator
var topSprite : AnimatedSprite2D
var bottomSprite : Sprite2D
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

var ignitionRounds : bool = false
var ignitionRoundsBurnTime = 0
var ignitionRoundsBurnDamage = 0

var goldenBuff : bool = false

func _process(_delta: float) -> void:
	get_tree().call_group("Turret", "attack")

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		hideUI()

func applyProjectileModifiers(proj) -> void:
	if ignitionRounds:
		proj.burn = true 
		proj.burnTime = ignitionRoundsBurnTime
		proj.burnDamage = ignitionRoundsBurnDamage


func showRange():
	line2d.show()

func hideRange():
	line2d.hide()

func getName():
	return turretName

func getCost():
	return price

func refreshUI(turretInstance):
	if not turretInstance is Dummy:
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
	if not self is Dummy:
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

func removeBubble(enemyPopped : bool):
	if currentParticlesMap.has("Bubble"):
		currentParticlesMap.get("Bubble").queue_free()
		currentParticlesMap.erase("Bubble")
	turretProviders.get("bubble").currentBubblesGiven -= 1
	if enemyPopped:
		var turretApplier = turretProviders.get("bubble")
		if turretApplier.level >= 3:
			var fxData = {
				"knockbackVelocity": turretApplier.knockbackVelocity,
				"explosionRadius": turretApplier.baseKnockbackRange,
				"stunTime": turretApplier.stunTime
			}
			ExplosionManager.summonExplosion(turretApplier,self.global_position,fxData)
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
	#print("called")
	for key in turretProviders:
		match key:
			"energized":
				if is_instance_valid(turretProviders.get("energized")):
					if turretProviders.get("energized").level >= 3:
						summonEnergizeExplosion()
					if turretProviders.get("energized").turretsEnergized -1 > 0:
						turretProviders.get("energized").turretsEnergized -= 1
					turretProviders.erase("energized")
			"bubble":
				removeBubble(false)
	StatManager.addStat(turretID,"deaths",1)
	
	queue_free()

func giveIgnitionRounds(time, burnTime, burnDamage):
	if not currentParticlesMap.has("Ignition Rounds"):
		ParticleManager.playIgnitionRoundsParticle(self)
	if effects.has("Ignition Rounds"):
		effects.get("Ignition Rounds").wait_time = time
		effects.get("Ignition Rounds").start()
	else:
		var timer = Timer.new()
		
		add_child(timer) 
		
		ignitionRoundsBurnDamage = burnDamage
		ignitionRoundsBurnTime = burnTime
		ignitionRounds = true
		
		timer.wait_time = time
		timer.one_shot = true
		timer.timeout.connect(removeIgnitionRounds)
		timer.start()
		
		effects["Ignition Rounds"] = timer

func removeIgnitionRounds():
	if currentParticlesMap.has("Ignition Rounds"):
		currentParticlesMap.get("Ignition Rounds").queue_free()
		currentParticlesMap.erase("Ignition Rounds")
	
	if effects.has("Ignition Rounds"):
		var timer = effects.get("Ignition Rounds")
		if is_instance_valid(timer):
			timer.queue_free()
			
	effects.erase("Ignition Rounds")
	ignitionRounds = false
	ignitionRoundsBurnDamage = 0
	ignitionRoundsBurnTime = 0

func giveGoldenBuff(turretApplier):
	var gold_material = load("res://Shaders/golden.tres")
	bottomSprite.material = gold_material
	turretProviders["golden"] = turretApplier
	goldenBuff = true

func removeGoldenBuff():
	bottomSprite.material = null
	currentParticlesMap.erase("Golden Buff")
	turretProviders.erase("golden")
	goldenBuff = false
