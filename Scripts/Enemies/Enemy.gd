extends CharacterBody2D

class_name Enemy

# TODO REWORK FOR THIS TO HAVE INHERITANCE

signal hit(damageTaken,turret,enemy,damageType)

var destination = null

var effects = []

var curseDamageAmp

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

func getName():
	return enemyName

func getDestination():
	if GameManager.inWave:
		destination = GameManager.getBeaconPosition()
	else:
		if DeveloperMode.inDevMode:
			destination = Vector2(960,540) # Center
