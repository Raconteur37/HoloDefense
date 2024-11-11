extends CharacterBody2D

var destination

var projectile = preload("res://Textures/Projectiles/DiamondProjectile.png")

@export var enemyName : String = "Shooty Diamond"
@export var health : float = 40
@export var damage : float = 20
@export var attackTime : float = 4
@export var speed : float = 25
@export var attackRange : float = 400
@export var projectileSpeed : float = 400

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
		takeDamage(body)
		body.queue_free()

func getName():
	return enemyName

func _on_attack_timer_timeout() -> void:
	while true:
		var areaArray : Array = $Area2D.get_overlapping_areas()
		while true:
			var turret = areaArray.pick_random()
			if turret.get_parent().is_in_group("Turret") and turret.name.contains("SelectArea"):
				var proj = projectile.instantiate()
				proj.position = position
				proj.linear_velocity = (turret.position - position).normalized() * projectileSpeed
				
				var dif = self.global_position.angle_to_point(turret.global_position)
				
				proj.rotation = proj.rotation + dif
				proj.damage = damage
				proj.shooter = self
				get_parent().add_child(proj)
				
				$AttackTimer.start()
				break
		break
			
func increaseStats():
	var currentWave = GameManager.currentWave
	
	var statIncrease = (currentWave / 10) * .05
	
	health += GameManager.round_to_dec(health * statIncrease,2)
	damage += GameManager.round_to_dec(damage * statIncrease,2)
	attackTime -= GameManager.round_to_dec(attackTime * statIncrease,2)
	speed += GameManager.round_to_dec(speed * statIncrease,2)
