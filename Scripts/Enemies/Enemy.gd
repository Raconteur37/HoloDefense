extends CharacterBody2D

class_name Enemy

enum EnemyID { NONE, BASIC_SQUARE, SPEEDY_TRIANGLE, SHOOTY_DIAMOND, HEXAGON_MOTHERSHIP}

enum Type {BASIC, BOSS, ELITE}

var enemyName: String
var health: float
var damage: float
var attackTime: float
var speed: float
var attackRange : float
var projectileSpeed : float
var type : Type

var hitBoxArea

var destination: Vector2 = Vector2.ZERO
var effects: Dictionary[EffectClass.Effect, EffectClass] = {} # Key is effect enum, val is the effect object
var curseDamageAmp: float = 0.0
var isDead: bool = false
var targeted: bool = false
var enemyID: EnemyID
var hurtParticle: CPUParticles2D

# Zombie state
var isZombie: bool = false
var initialTurn: bool = false
var turnTurret
var zombieFollowTarget: Enemy = null

var attackReady: bool = true
var attackTimer: Timer

func _ready() -> void:
	attackTimer = Timer.new()
	attackTimer.wait_time = attackTime
	attackTimer.one_shot = true
	attackTimer.timeout.connect(_on_attack_timer_timeout)
	add_child(attackTimer)

func _physics_process(delta: float) -> void:
	updateDestination()
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
		if collider.is_in_group("Turret"):
			velocity = Vector2.ZERO
			# Push enemy back out of overlap
			global_position += col.get_normal() * speed * get_physics_process_delta_time()
			if attackReady:
				EntityManager.turretTakeDamage(damage, collider)
				startAttackCooldown()
			return
	if global_position.distance_to(destination) < 5.0:
		velocity = Vector2.ZERO
		global_position = destination

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
	set_collision_mask_value(3,true)
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
	timer.wait_time = 3
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(onZombieTimerTimeout)
	add_child(timer)

func onZombieTimerTimeout() -> void:
	var dmg = turnTurret.damage if is_instance_valid(turnTurret) else 9999
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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Turret"):
		if type != Type.BOSS:
			startAttackCooldown()
			EntityManager.turretTakeDamage(damage,body)
		else:
			EntityManager.turretTakeDamage(damage,body)


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
