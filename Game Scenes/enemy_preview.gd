extends CanvasLayer

@onready var enemyPosNode = $EnemyPosition
@onready var dummy = $Dummy
@onready var timer : Timer = $Timer

var enID
var enemy


func _ready() -> void:
	pass
	#spawnEnemy(Enemy.EnemyID.PACKED_CIRCLE)

func spawnEnemy(enemyID : Enemy.EnemyID):
	enID = enemyID
	match enemyID:
		Enemy.EnemyID.BASIC_SQUARE:
			enemy = load("res://Enemy Scenes/Basic Square.tscn").instantiate()
			add_child(enemy)
			enemy.global_position = enemyPosNode.global_position
			enemy.specificDir = dummy.global_position
		Enemy.EnemyID.SPEEDY_TRIANGLE:
			enemy = load("res://Enemy Scenes/Speedy Triangle.tscn").instantiate()
			add_child(enemy)
			enemy.global_position = enemyPosNode.global_position
			enemy.specificDir = dummy.global_position
		Enemy.EnemyID.TANKY_RECTANGLE:
			enemy = load("res://Enemy Scenes/Tanky Rectangle.tscn").instantiate()
			add_child(enemy)
			enemy.global_position = enemyPosNode.global_position
			enemy.specificDir = dummy.global_position
		Enemy.EnemyID.PACKED_CIRCLE:
			timer.wait_time = 6
			timer.start()
			enemy = load("res://Enemy Scenes/Packed Circle.tscn").instantiate()
			add_child(enemy)
			enemy.global_position = enemyPosNode.global_position
			enemy.specificDir = dummy.global_position
			await get_tree().create_timer(3).timeout
			enemy.hide()
			var explosion = load("res://Particle Scenes/Enemies/packedExplosion.tscn").instantiate()
			add_child(explosion)
			explosion.global_position = enemy.global_position
			explosion.emitting = true
			for i in range(5):
				packedCicle(enemy)
		Enemy.EnemyID.SHOOTY_DIAMOND:
			enemy = load("res://Enemy Scenes/Shooty Diamond.tscn").instantiate()
			enemy.turretsInRange.append(dummy)
			add_child(enemy)
			enemy.global_position = enemyPosNode.global_position
			enemy.specificDir = dummy.global_position
		Enemy.EnemyID.HEXAGON_MOTHERSHIP:

			
			enemy = load("res://Enemy Scenes/Hexagon Mothership.tscn").instantiate()
			add_child(enemy)
			enemy.global_position = enemyPosNode.global_position
			enemy.global_position.y += 100
			enemy.scale = Vector2(1.7,1.7)
			
			timer.wait_time = 15
			timer.start()
			
			if is_instance_valid(dummy):
				dummy.queue_free()
			
			await get_tree().create_timer(2).timeout
			
			for x in range(20):
				mothershipSpawn(enemy)
				await get_tree().create_timer(0.1).timeout

func packedCicle(circle):
	var tempEnemy = load("res://Enemy Scenes/Mini Packed Circle.tscn").instantiate()
	
	add_child(tempEnemy) 
	
	tempEnemy.global_position = circle.global_position

	# Launch outward
	var angle = randf_range(0, 2 * PI)
	var direction = Vector2(cos(angle), sin(angle)).normalized()
	tempEnemy.set_physics_process(false)

	var tween = tempEnemy.create_tween()
	tween.tween_property(
		tempEnemy,
		"global_position",
		circle.global_position + direction * 120.0,
		0.6
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(func():
		tempEnemy.set_physics_process(true)
		tempEnemy.specificDir = Vector2(1000,1000)
	)

func mothershipSpawn(mothership):
	const ENEMIES = {
			Enemy.EnemyID.BASIC_SQUARE: preload("res://Enemy Scenes/Basic Square.tscn"),
			Enemy.EnemyID.SPEEDY_TRIANGLE: preload("res://Enemy Scenes/Speedy Triangle.tscn"),
			Enemy.EnemyID.SHOOTY_DIAMOND: preload("res://Enemy Scenes/Shooty Diamond.tscn"),
			Enemy.EnemyID.HEXAGON_MOTHERSHIP: preload("res://Enemy Scenes/Hexagon Mothership.tscn"),
			Enemy.EnemyID.TANKY_RECTANGLE: preload("res://Enemy Scenes/Tanky Rectangle.tscn")
	}
	var randNum = randf_range(0, 100)
	var tempEnemy
	if randNum <= 75:
		tempEnemy = ENEMIES[Enemy.EnemyID.BASIC_SQUARE].instantiate()
	elif randNum <= 90:
		if randf_range(0,100) < 50:
			tempEnemy = ENEMIES[Enemy.EnemyID.SPEEDY_TRIANGLE].instantiate()
		else:
			tempEnemy = ENEMIES[Enemy.EnemyID.TANKY_RECTANGLE].instantiate()
	else:
		tempEnemy = ENEMIES[Enemy.EnemyID.SHOOTY_DIAMOND].instantiate()
	
	add_child(tempEnemy)
	tempEnemy.global_position = mothership.global_position

	# Launch outward
	var angle = randf_range(0, 2 * PI)
	var direction = Vector2(cos(angle), sin(angle)).normalized()
	tempEnemy.set_physics_process(false)

	var tween = tempEnemy.create_tween()
	tween.tween_property(
		tempEnemy,
		"global_position",
		mothership.global_position + direction * 120.0,
		0.6
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(func():
		tempEnemy.set_physics_process(true)
		tempEnemy.specificDir = Vector2(1000,1000)
	)

func _on_timer_timeout() -> void:
	enemy.queue_free()
	spawnEnemy(enID)
