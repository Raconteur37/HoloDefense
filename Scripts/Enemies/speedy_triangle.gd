extends CharacterBody2D

var destination

@export var enemyName : String = "Speedy Triangle"
@export var health : float = 30
@export var damage : float = 20
@export var attackTime : float = .5
@export var speed : float = 200

var attackTimer
var attackReady : bool = true
var isDead : bool = false

func takeDamage(projBody):
	var damageTaken = projBody.damage
	if health - damageTaken <= 0 and not isDead:
		GameManager.onKill(projBody.shooter,self)
		isDead = true
		await get_tree().create_timer(.1).timeout
		queue_free()
	else:
		health = health - damageTaken

func _ready():
	attackTimer = $AttackTimer
	attackTimer.wait_time = attackTime
	destination = GameManager.getBeaconPosition()
	increaseStats()

func _physics_process(delta: float) -> void:
	
	var direction = (destination - global_position).normalized()
	# Set the velocity to move toward the center
	velocity = direction * speed

	look_at(destination)

	# Move and Slide with the current velocity
	move_and_slide()

	# Stop moving when close to the center to prevent overshooting
	if global_position.distance_to(destination) < 5.0:
		velocity = Vector2.ZERO
		global_position = destination


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Turret Projectile"):
		takeDamage(body)
		body.queue_free()

func getName():
	return enemyName

func _on_attack_timer_timeout() -> void:
	attackReady = true
	for x in $Area2D.get_overlapping_areas():
		if x.get_parent().is_in_group("Turret") and x.name.contains("SelectArea"):
			x.get_parent().takeDamage(damage)
			attackReady = false
			attackTimer.start()

func increaseStats():
	var currentWave = GameManager.currentWave
	
	var statIncrease = (currentWave / 10) * .02
	
	health += GameManager.round_to_dec(health * statIncrease,2)
	damage += GameManager.round_to_dec(damage * statIncrease,2)
	attackTime -= GameManager.round_to_dec(attackTime * statIncrease,2)
	speed += GameManager.round_to_dec(speed * statIncrease,2)
