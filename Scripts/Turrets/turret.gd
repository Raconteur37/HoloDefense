extends CharacterBody2D

class_name Turret

var targetCursor = load("res://Textures/UI/Cursor/targetCursor.png")

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
	MORTAR_TURRET,
	SHIELD_TURRET
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

var preview : bool = false

enum Rarity { COMMON, RARE, SUPER_RARE, LEGENDARY, UNSEEN}
var rarity : Rarity
enum Type {CONSISTENT, SUPPORTIVE, CHAOTIC, DEBUFFER, TANKY, CONTROLLING, FORTUITOUS, EXPLOSIVE, SUMMONER, IMPACTFUL}
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

# -= Target =-
var target = null
var priorityTarget = null

var priorityType = "None"

var isHovering : bool = false
var isTargetDragging : bool = false
var targetLine : Line2D
var manualTarget = null
var lineAnimTime : float = 0.0

func _ready() -> void:
	GameManager.updatePriorities()

func createLine():
	if targetLine != null:
		targetLine.queue_free()
	
	toggleTargetEnemyHighlight(true)
	GameManager.turretTargetToggle = true
	GameManager.turretTargetting = self
	
	targetLine = Line2D.new()
	targetLine.width = 4.0
	targetLine.default_color = Color(1.0, 0.2, 0.2, 0.8)
	targetLine.z_index = 10
	
	# Smooths out the ends of the line
	targetLine.begin_cap_mode = Line2D.LINE_CAP_ROUND
	targetLine.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	targetLine.hide()
	add_child(targetLine)

func _process(delta: float) -> void:
	attack()
	
	if isTargetDragging:
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			stopDragging()
			return
			
		if is_instance_valid(targetLine):
			targetLine.set_point_position(1, get_local_mouse_position())
			
			lineAnimTime += delta * 15.0 
			targetLine.width = 4.0 + (sin(lineAnimTime) * 2.0)
			var alpha = 0.5 + (sin(lineAnimTime * 1.5) * 0.5) 
			targetLine.default_color = Color(1.0, 0.3 + (alpha * 0.4), 0.3, 0.4 + (alpha * 0.6))

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		hideUI()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and isHovering and not isTargetDragging:
			createLine()
			isTargetDragging = true
			targetLine.clear_points()
			targetLine.add_point(Vector2.ZERO)
			targetLine.add_point(get_local_mouse_position())
			targetLine.show()
			
			# Prevents other turrets or nodes behind this from also responding to the click
			get_viewport().set_input_as_handled()
			
		elif not event.is_pressed() and isTargetDragging:
			stopDragging()

func stopDragging() -> void:
	isTargetDragging = false
	
	toggleTargetEnemyHighlight(false)
	#print(target)
	GameManager.turretTargetToggle = false
	targetLine.hide()
	
	if not isHovering:
		hideUI()
		clearCursor()

func applyProjectileModifiers(proj) -> void:
	if ignitionRounds:
		proj.burn = true 
		proj.burnTime = ignitionRoundsBurnTime
		proj.burnDamage = ignitionRoundsBurnDamage

func changeCursor():
	Input.set_custom_mouse_cursor(targetCursor)

func clearCursor():
	Input.set_custom_mouse_cursor(null)

func showRange():
	line2d.show()

func hideRange():
	line2d.hide()

func getName():
	return turretName

func getCost():
	return price

func refreshUI(turretInstance):
	if preview:
		return
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
	if preview:
		return
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

func reapplyEnergize():
	if is_instance_valid(turretProviders.get("energized")):
		turretProviders.get("energized").removeEnergizerBuffsToTurret(self)
		turretProviders.get("energized").applyEnergizerBuffsToTurret(self)

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
	var expDmg = TurretManager.getTurretStat(Turret.TurretID.ENERGIZER_TURRET,"energizeExplosionDamage")
	var expRange = TurretManager.getTurretStat(Turret.TurretID.ENERGIZER_TURRET,"energizeExplosionRange")
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
	toggleTargetEnemyHighlight(false)
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

func _on_select_area_mouse_entered() -> void:
	toggleTargetEnemyHighlight(true)
	isHovering = true
	showUI(self)
	changeCursor()

func _on_select_area_mouse_exited() -> void:
	isHovering = false
	toggleTargetEnemyHighlight(false)
	# Only hide UI if we aren't currently dragging a line out of the turret
	if not isTargetDragging:
		hideUI()
		clearCursor()

func toggleTargetEnemyHighlight(toggle):
	if toggle:
		if is_instance_valid(manualTarget):
			manualTarget.highlight_target(true)
		else:
			manualTarget = null
	else:
		if is_instance_valid(manualTarget):
			manualTarget.highlight_target(false)

func filterEnemy():
	if is_instance_valid(manualTarget) and enemiesInRange.has(manualTarget):
		return manualTarget
		
	var closest_priority_enemy = null
	var shortest_dist = INF
	
	for en in enemiesInRange:
		if is_instance_valid(en) and en.enemyID == priorityTarget:
			var dist = global_position.distance_squared_to(en.global_position)
			if dist < shortest_dist:
				shortest_dist = dist
				closest_priority_enemy = en
				

	if priorityType == "High":
		return closest_priority_enemy
		
	if priorityType == "Medium" and closest_priority_enemy != null:
		return closest_priority_enemy
		
	return EntityManager.getClosestEnemyFromSprite(self)

func attack():
	return
