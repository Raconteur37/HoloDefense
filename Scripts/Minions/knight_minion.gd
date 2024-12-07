extends CharacterBody2D

signal hit(damage,minion)

enum Type {Minion}

const minionName : String = "Knight"
var health : float = 0
var damage : float = 0
@export var attackTime : float = 3
@export var speed : float = 200 
@export var armor : int = 10

var attackTimer
var idleTimer
var attackReady : bool = true
var isDead : bool = false
var attackingEnemy : bool = false
var moveBack : bool = true
var enemy = null
var turretOwner
var shooter = self

var enemiesList = []

func _ready():
	attackTimer = $AttackTimer
	idleTimer = $IdleTimer
	attackTimer.wait_time = attackTime
	var angle = randf_range(0, 2 * PI)
	var direction = (Vector2(cos(angle), sin(angle))).normalized()
	velocity = direction * 200
	await get_tree().create_timer(.2).timeout
	velocity = Vector2(0,0)
	
	hit.connect(EntityManager.entityTakeDamage)

func getName():
	return minionName

func _physics_process(delta: float) -> void:
	
	if enemy == null:
		attackingEnemy = false
		for z in turretOwner.get_node("RangeArea").get_overlapping_areas():
			if z.get_parent().is_in_group("Enemy"):
				enemiesList.append(z.get_parent())
		if enemiesList.size() > 0:
			enemy = enemiesList.pick_random()
			attackingEnemy = true
			enemiesList.clear()
	
	if attackingEnemy and enemy != null:
		var direction = (enemy.global_position - global_position).normalized()
		# Set the velocity to move toward the center
		velocity = direction * speed

		# Move and Slide with the current velocity
		move_and_slide()
	
	if not attackingEnemy:
		if idleTimer.is_stopped():
			idleTimer.start()
		move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		if attackReady:
			body.hit.emit(damage,turretOwner,body,self)
			attackReady = false
			attackTimer.start()

func _on_attack_timer_timeout() -> void:
	attackReady = true
	if enemy != null:
		for x in $Area2D.get_overlapping_areas():
			if x.get_parent() == enemy:
				enemy.hit.emit(damage,turretOwner,x.get_parent(),self)
				attackReady = false
		attackTimer.start()


func _on_idle_timer_timeout() -> void:
	if not attackingEnemy:
		var rand = randi_range(0,1)
		if rand == 0:
			var angle = randf_range(0, 2 * PI)
			var direction = (Vector2(cos(angle), sin(angle))).normalized()
			velocity = direction * 100
			await get_tree().create_timer(.5).timeout
			velocity = Vector2(0,0)
		else:
			var direction = (turretOwner.global_position - global_position).normalized()
			velocity = direction * 100
			await get_tree().create_timer(.5).timeout
			velocity = Vector2(0,0)
		idleTimer.start()
