extends Node2D

@onready var tickTimer : Timer = $TickTimer
@onready var riftParticle = $Rift
@onready var totalEnemies = WaveManager.getRiftEventEnemiesSpawned()

var location

var tracker = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("FadeIn")
	startRift()

func pickRandomPos():
	var view_rect = get_viewport().get_visible_rect()
	var margin = 140 
	
	var side = randi_range(1,2)
	var spawn_pos = Vector2.ZERO
	
	match side:
		1: # Left
			spawn_pos.x = +margin
			spawn_pos.y = randf_range(0, view_rect.size.y)
		2: # Right
			spawn_pos.x = view_rect.size.x - margin
			spawn_pos.y = randf_range(0, view_rect.size.y)
			
	return spawn_pos


func startRift():
	location = pickRandomPos()
	tickTimer.wait_time = WaveManager.getRiftEventEnemySpawnInterval()
	riftParticle.global_position = location
	
	tickTimer.start()



func _on_tick_timer_timeout() -> void:
	var enemy = EnemySpawnManager.NON_BOSS_ENEMIES.keys().pick_random()
	enemy = EnemySpawnManager.NON_BOSS_ENEMIES[enemy].instantiate()
	tracker += 1
	var holder = get_tree().current_scene.find_child("EnemyNodeHolder")
	holder.add_child(enemy)
	enemy.global_position = location
	WaveManager.registerActiveEnemy(enemy)

	# Launch outward
	var angle = randf_range(0, 2 * PI)
	var direction = Vector2(cos(angle), sin(angle)).normalized()
	enemy.set_physics_process(false)

	var tween = enemy.create_tween()
	tween.tween_property(
		enemy,
		"global_position",
		location + direction * 120.0,
		0.6
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(func():
		enemy.set_physics_process(true)
		enemy.getDestination()
	)
	if tracker >= totalEnemies:
		$AnimationPlayer.play("FadeOut")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeOut":
		queue_free()
