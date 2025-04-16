extends CharacterBody2D

class_name Enemy

signal hit(damageTaken,turret,enemy,damageType)

var destination = null

var effects = []

var curseDamageAmp

var initialTurn = false
var turnTurret
var isZombie

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
			
			var awayDirection = (to_local(global_position) - to_local(turnTurret.global_position)).normalized()
			
			destination = (to_local(global_position) - to_local(awayDirection)) * 300

func onZombieTimerTimeout():
	if is_instance_valid(turnTurret):
		hit.emit(turnTurret.damage,turnTurret,self,turnTurret)
	else:
		hit.emit(9999,null,self,null)

func onZombieAreaEntered(body):
	if body.is_in_group("Enemy"):
		if turnTurret.get("turnChance") != null:
			if randi_range(0,100) <= turnTurret.turnChance:
				body.turnTurret = turnTurret
				body.isZombie = true
		else:
			if randi_range(0,100) <= 10:
				body.turnTurret = turnTurret
				body.isZombie = true

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
