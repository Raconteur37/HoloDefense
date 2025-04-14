extends CharacterBody2D

class_name Enemy

# TODO REWORK FOR THIS TO HAVE INHERITANCE

signal hit(damageTaken,turret,enemy,damageType)

var destination

var effects = []

@export var enemyName : String
@export var health : float
@export var damage : float
@export var attackTime : float
@export var speed : float

var attackTimer
var attackReady : bool = true
var isDead : bool = false

func _ready():
	enemyName = "Debug"
	health = -1
	damage = -1
	attackTime = -1
	speed = -1
	attackTimer = $AttackTimer
	attackTimer.wait_time = attackTime

	hit.connect(EntityManager.takeDamage)

	EntityManager.increaseStats()

func _physics_process(delta: float) -> void:

	var direction = (destination - global_position).normalized()
	# Set the velocity to move toward the center
	velocity = direction * speed

	# Move and Slide with the current velocity
	move_and_slide()

	# Stop moving when close to the center to prevent overshooting
	if global_position.distance_to(destination) < 5.0:
		velocity = Vector2.ZERO
		global_position = destination


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

func getName():
	return enemyName

func _on_attack_timer_timeout() -> void:
	attackReady = true
	for x in $Area2D.get_overlapping_areas():
		var entity = x.get_parent()
		if entity.is_in_group("Turret") and x.name.contains("SelectArea"):
			entity.hit.emit(damage,entity)
			attackReady = false
			attackTimer.start()

func getDestination():
	if GameManager.inWave:
		destination = GameManager.getBeaconPosition()
	else:
		if DeveloperMode.inDevMode:
			destination = Vector2(960,540) # Center
