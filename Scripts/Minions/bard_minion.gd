extends Minion

var particleEffective = preload("res://Particle Scenes/Minion/bard_effective.tscn")

var attackTimer : Timer
var idleTimer
var attackReady : bool = true
var moveBack : bool = true
@onready var particle = $BardHeal
var healAmount : float

func _ready():
	id = MinionID.BARD
	attackTimer = $AttackTimer
	idleTimer = $IdleTimer
	attackTimer.wait_time = attackTime
	sprite = $Sprite2D
	var angle = randf_range(0, 2 * PI)
	var direction = (Vector2(cos(angle), sin(angle))).normalized()
	velocity = direction * speed
	await get_tree().create_timer(.2).timeout
	velocity = Vector2(0,0)

func updateAttackTime():
	attackTimer.wait_time = attackTime

func _physics_process(delta: float) -> void:
	if idleTimer.is_stopped():
		idleTimer.start()
	move_and_slide()

func _on_attack_timer_timeout() -> void:
	heal()

func heal():
	particle.emitting = true
	spin()
	for minion : Minion in turretOwner.currentMinions:
		if minion != self:
			var part = particleEffective.instantiate()
			minion.add_child(part)
			part.global_position = minion.global_position
			part.global_position.y += 5
			if minion.health + healAmount >= minion.maxHealth:
				minion.health = minion.maxHealth
			else:
				minion.health += healAmount

func spin():
	var tween = create_tween()
	
	tween.tween_property(self, "rotation_degrees", 360.0, 0.5).as_relative()
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

func _on_idle_timer_timeout() -> void:
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
