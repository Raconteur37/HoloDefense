extends CharacterBody2D

class_name Enemy

enum EnemyID { NONE, BASIC_SQUARE, SPEEDY_TRIANGLE, SHOOTY_DIAMOND, HEXAGON_MOTHERSHIP, TANKY_RECTANGLE, PACKED_CIRCLE}
enum Type {BASIC, BOSS, ELITE}

var enemyName: String
var health: float
var damage: float
var attackTime: float
var speed: float
var attackRange : float
var projectileSpeed : float
var type : Type
var tier : int

var sprite : Sprite2D
var hitBoxArea

var destination: Vector2 = Vector2.ZERO
var effects: Dictionary = {} # Key is effect enum, val is the effect object
var curseDamageAmp: float = 0.0
var isDead: bool = false
var targeted: bool = false
var enemyID: EnemyID
var hurtParticle: CPUParticles2D

# Zombie state
var isZombie: bool = false
var zombieTime : float = false
var initialTurn: bool = false
var turnTurret
var zombieFollowTarget: Enemy = null

# Attack logic
var attackReady: bool = true
var attackTimer: Timer
var turretsInRange: Array = []

var stunned : bool = false

var is_sent_enemy: bool = false  # true when spawned by another player sending it

func _ready() -> void:
	applyScaling()
	attackTimer = Timer.new()
	attackTimer.wait_time = attackTime
	attackTimer.one_shot = true
	attackTimer.timeout.connect(_on_attack_timer_timeout)
	
	# Must add the timer to the tree so it can tick!
	add_child(attackTimer)

func _physics_process(delta: float) -> void:
	if is_sent_enemy and not multiplayer.is_server():
		return
	
	if stunned:
		return

	updateDestination()

	# Clean out any turrets from the array that were recently destroyed
	turretsInRange = turretsInRange.filter(func(t): return is_instance_valid(t))

	# If there is a turret in our Area2D range, STOP and attack it
	if turretsInRange.size() > 0:
		velocity = Vector2.ZERO
		
		if attackReady:
			var targetTurret = turretsInRange[0]
			EntityManager.turretTakeDamage(damage, targetTurret, null,self)
			startAttackCooldown()
	else:
		# No turrets in Area2D range, keep walking!
		move()

	if isZombie and not initialTurn and type != Type.BOSS:
		initZombie()

func updateDestination() -> void:
	if zombieFollowTarget != null:
		if not is_instance_valid(zombieFollowTarget) or zombieFollowTarget.isDead:
			zombieFollowTarget = GameManager.getRandomEnemyAlive()
		if zombieFollowTarget != null:
			destination = zombieFollowTarget.global_position
	elif destination == Vector2.ZERO:
		getDestination()

func move() -> void:
	if destination == Vector2.ZERO:
		return
		
	var direction = (destination - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		
		if collider.is_in_group("Turret") or collider.is_in_group("Minion"):
			# Calculates the angle of impact. 
			# -1.0 means a head-on collision. 0.0 means sliding perfectly alongside it.
			var impact_angle = direction.dot(col.get_normal())
			
			# If the angle is less than -0.4, the turret is actually blocking our forward path
			if impact_angle < -0.4:
				velocity = Vector2.ZERO
				
				if attackReady:
					EntityManager.turretTakeDamage(damage, collider, null,self)
					startAttackCooldown()
				return 

func initZombie() -> void:
	if not is_instance_valid(turnTurret):
		return
	initialTurn = true
	WaveManager.removeActiveEnemy(self)
	modulate = Color('#00ba00')
	spawnZombieArea()
	startZombieTimer()
	destination = EnemySpawnManager.getRandomOffscreenPosition()
	set_collision_layer_value(3,false)
	set_collision_layer_value(1,true)
	set_collision_mask_value(1,false)
	set_collision_mask_value(2,false)
	
func spawnZombieArea() -> void:
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 75
	shape.shape = circle
	area.set_collision_layer_value(1, true)
	area.set_collision_mask_value(3, true)
	area.add_child(shape)
	area.body_entered.connect(onZombieAreaEntered)
	area.body_exited.connect(onZombieAreaExit)
	add_child(area)

func startZombieTimer() -> void:
	var timer = Timer.new()
	timer.wait_time = turnTurret.get("turnTime") if is_instance_valid(turnTurret) else 3
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(onZombieTimerTimeout)
	add_child(timer)

func onZombieTimerTimeout() -> void:
	var dmg = 9999
	var packet = DamagePacket.new(dmg, DamagePacket.Type.TURRET, turnTurret)
	EntityManager.enemyTakeDamage(packet, self)

func onZombieAreaEntered(body: Node) -> void:
	if not body.is_in_group("Enemy") or body.isZombie:
		return
	var chance = turnTurret.get("turnChance") if is_instance_valid(turnTurret) else 10
	if randi_range(0, 100) <= chance:
		body.turnTurret = turnTurret
		body.isZombie = true
		ParticleManager.playZombieTurnParticle(self)

func onZombieAreaExit(_body: Node) -> void:
	pass

# --- New Area2D Logic for Ranged Turret Detection ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Turret") and not turretsInRange.has(body):
		turretsInRange.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Turret"):
		turretsInRange.erase(body)
# ----------------------------------------------------

func startAttackCooldown() -> void:
	if type != Type.BOSS:
		attackReady = false
		attackTimer.start()

func _on_attack_timer_timeout() -> void:
	attackReady = true

func getDestination() -> void:
	destination = get_viewport().get_visible_rect().size / 2

func getName() -> String:
	return enemyName

func applyScaling() -> void:
	var totalWaves = (WaveManager.systemNumber * WaveManager.getWavesPerSystem()) + WaveManager.currentWave - 1

	var waveHealthMult = pow(WaveManager.getHealthScalePerWave(), totalWaves)
	var waveDamageMult = pow(WaveManager.getDamageScalePerWave(), totalWaves)

	health *= waveHealthMult
	damage *= waveDamageMult
	health = round(health)
	damage = round(damage)

func getEnemyTier():
	return tier
