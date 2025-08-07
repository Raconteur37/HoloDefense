extends CharacterBody2D

class_name Enemy

signal hit(damageTaken,turret,enemy,damageType)

var destination = null

var effects : Dictionary = {}

var curseDamageAmp

var initialTurn = false
var turnTurret
var isZombie
var zombieFollowTarget : Enemy = null

var targeted : bool = false

@export var enemyName : String
@export var health : float
@export var damage : float
@export var attackTime : float
@export var speed : float

var attackTimer
var attackReady : bool = true
var isDead : bool = false

func _physics_process(delta: float) -> void:

	if destination == null:
		getDestination()
	if zombieFollowTarget != null:
		if zombieFollowTarget.isZombie:
			if GameManager.enemiesAlive.is_empty():
				hit.emit(9999,turnTurret,self,turnTurret) # Damage, Turret, Enemy, Damage Type
			zombieFollowTarget = GameManager.getRandomEnemyAlive()
		else:
			destination = zombieFollowTarget.global_position

	var direction = (destination - global_position).normalized()
	# Set the velocity to move toward the center
	velocity = direction * speed

	# Move and Slide with the current velocity
	move_and_slide()

	# Stop moving when close to the center to prevent overshooting
	if global_position.distance_to(destination) < 5.0:
		velocity = Vector2.ZERO
		global_position = destination

	if isZombie and not initialTurn: # Turn them into a zombie
		if is_instance_valid(self) and is_instance_valid(turnTurret):
			GameManager.enemiesAlive.erase(self)
			initialTurn = true
			modulate = Color('#00ba00')
			var timer = Timer.new()
			timer.name = "ZombieTimer"
			timer.timeout.connect(onZombieTimerTimeout.bind())
			timer.wait_time = 3
			timer.autostart = true
			add_child(timer)

			var area = Area2D.new()
			area.body_entered.connect(onZombieAreaEntered.bind())
			area.body_exited.connect(onZombieAreaExit.bind())
			var shape = CollisionShape2D.new()
			var circle = CircleShape2D.new()
			circle.radius = 75
			shape.shape = circle
			area.global_position = to_local(global_position)
			area.set_collision_layer_value(1,true)
			area.set_collision_mask_value(3,true)
			area.add_child(shape)
			add_child(area)

			if not is_instance_valid(zombieFollowTarget):
				if not GameManager.enemiesAlive.is_empty():
					zombieFollowTarget = GameManager.getRandomEnemyAlive()
					destination = zombieFollowTarget.global_position
				else:
					destination = GameManager.generateRandomPosition()

func onZombieTimerTimeout():
	if is_instance_valid(turnTurret):
		hit.emit(turnTurret.damage,turnTurret,self,turnTurret)
	else:
		hit.emit(9999,null,self,null)

func onZombieAreaEntered(body):
	if body.is_in_group("Enemy") and not body.isZombie:
		if turnTurret.get("turnChance") != null:
			if randi_range(0,100) <= turnTurret.turnChance:
				body.turnTurret = turnTurret
				body.isZombie = true
				ParticleManager.playZombieTurnParticle(self)
		else:
			if randi_range(0,100) <= 10:
				body.turnTurret = turnTurret
				body.isZombie = true
				ParticleManager.playZombieTurnParticle(self)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Turret Projectile"):
		hit.emit(body.damage,body.shooter,self,body)
	if body.is_in_group("Turret"):
		if body.get("isPlaced") != null:
			if body.isPlaced:
				body.hit.emit(damage,body)
				attackReady = false
				attackTimer.start()

	if body.is_in_group("Minion"):
		body.hit.emit(damage,body)
		attackReady = false
		attackTimer.start()

func onZombieAreaExit(body: Node2D):
	pass

func getName():
	return enemyName

func getDestination():
	if GameManager.inWave:
		destination = GameManager.getBeaconPosition()
	else:
		if DeveloperMode.inDevMode:
			destination = Vector2(960,540) # Center
