extends CharacterBody2D

var destination

var projectile = preload("res://Projectile Scenes/diamond.tscn")

@export var enemyName : String = "Shooty Diamond"
@export var health : float = 75
@export var damage : float = 20
@export var attackTime : float = 4
@export var speed : float = 25
@export var attackRange : float = 400
@export var projectileSpeed : float = 400

var attackTimer
var attackReady : bool = true
var isDead : bool = false

var turretsInRange = []

func takeDamage(damage,turret):
	var damageTaken = damage
	# This is so bad but it works for now so yeah
	if damageTaken > 99999:
		ParticleManager.playExecutionParticle(self)
	if health - damageTaken <= 0 and not isDead:
		GameManager.onKill(turret,self)
		isDead = true
	else:
		health = health - damageTaken

func _ready():
	attackTimer = $AttackTimer
	attackTimer.wait_time = attackTime
	attackTimer.start()
	#destination = Vector2(1000,0) 
	destination = GameManager.getBeaconPosition()
	increaseStats()
	$Area2D2/CollisionShape2D.shape.radius = attackRange

func _physics_process(delta: float) -> void:
	
	var direction = (destination - global_position).normalized()
	#look_at(direction)
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
		if body.get("enemiesPierced") != null:
			if body.enemiesPierced+1 >= body.maxEnemyPierce:
				takeDamage(body.damage,body.shooter)
				body.queue_free()
				return
			else:
				body.enemiesPierced += 1
				body.collision_mask = 999
				takeDamage(body.damage,body.shooter)
				if isDead:
					body.collision_mask = 3
				return
		takeDamage(body.damage,body.shooter)
		body.queue_free()

func getName():
	return enemyName

func _on_attack_timer_timeout() -> void:
	for x in turretsInRange:
		if not is_instance_valid(x):
			turretsInRange.erase(x)
	if turretsInRange.size() > 0:
		var turret = turretsInRange.pick_random()
		if is_instance_valid(turret):
			var proj = projectile.instantiate()
			proj.position = position
			proj.linear_velocity = (turret.position - position).normalized() * projectileSpeed
			
			var dif = self.global_position.angle_to_point(turret.global_position)
			
			proj.rotation = proj.rotation + dif
			proj.damage = damage
			proj.shooter = self
			get_parent().add_child(proj)
			
		else:
			turretsInRange.erase(turret)
	$AttackTimer.start()
			
func increaseStats():
	var currentWave = GameManager.currentWave
	
	var statIncrease = (currentWave / 10) * .05
	
	health += GameManager.round_to_dec(health * statIncrease,2)
	damage += GameManager.round_to_dec(damage * statIncrease,2)
	attackTime -= GameManager.round_to_dec(attackTime * statIncrease,2)
	speed += GameManager.round_to_dec(speed * statIncrease,2)


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Turret") and body.isPlaced:
		turretsInRange.append(body)
