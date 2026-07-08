extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Preload all your scenes at the top of the script
# This stores the "template" in memory once
const ENEMIES = {
	Enemy.EnemyID.BASIC_SQUARE: preload("res://Enemy Scenes/Basic Square.tscn"),
	Enemy.EnemyID.SPEEDY_TRIANGLE: preload("res://Enemy Scenes/Speedy Triangle.tscn"),
	Enemy.EnemyID.SHOOTY_DIAMOND: preload("res://Enemy Scenes/Shooty Diamond.tscn"),
	Enemy.EnemyID.HEXAGON_MOTHERSHIP: preload("res://Enemy Scenes/Hexagon Mothership.tscn"),
	Enemy.EnemyID.TANKY_RECTANGLE: preload("res://Enemy Scenes/Tanky Rectangle.tscn")
}

func summonEnemy(enemyID : Enemy.EnemyID):
	var holder = get_tree().current_scene.find_child("EnemyNodeHolder")
	
	#print("EnemySpawnManager attempting to spawn ID: ", enemyID)
	
	if holder and ENEMIES.has(enemyID):
		#print("1. Found the preloaded scene!")
		var enemy = ENEMIES[enemyID].instantiate()
		
		#print("2. Instantiated successfully! Adding to tree...")
		holder.add_child(enemy)
		
		enemy.global_position = getRandomOffscreenPosition()
		#print("3. Spawn fully complete.")
	else:
		push_error("Spawn failed: Holder not found or EnemyID invalid. ID received: ", enemyID)

func mothershipSpawn(mothership):
	var holder = get_tree().current_scene.find_child("EnemyNodeHolder")

	var randNum = randf_range(0, 100)
	var enemy
	if randNum <= 75:
		enemy = ENEMIES[Enemy.EnemyID.BASIC_SQUARE].instantiate()
	elif randNum <= 90:
		if randf_range(0,50) < 50:
			enemy = ENEMIES[Enemy.EnemyID.SPEEDY_TRIANGLE].instantiate()
		else:
			enemy = ENEMIES[Enemy.EnemyID.TANKY_RECTANGLE].instantiate()
	else:
		enemy = ENEMIES[Enemy.EnemyID.SHOOTY_DIAMOND].instantiate()

	holder.add_child(enemy)
	enemy.global_position = mothership.global_position
	WaveManager.registerActiveEnemy(enemy)

	# Launch outward
	var angle = randf_range(0, 2 * PI)
	var direction = Vector2(cos(angle), sin(angle)).normalized()
	enemy.set_physics_process(false)

	var tween = enemy.create_tween()
	tween.tween_property(
		enemy,
		"global_position",
		mothership.global_position + direction * 120.0,
		0.6
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(func():
		enemy.set_physics_process(true)
		enemy.getDestination()
	)

	#await get_tree().create_timer(0.05).timeout

func getRandomOffscreenPosition() -> Vector2:
	var view_rect = get_viewport().get_visible_rect()
	var margin = 50.0 
	
	var side = randi() % 6
	var spawn_pos = Vector2.ZERO
	
	match side:
		# Top
		0: 
			spawn_pos.x = randf_range(0, view_rect.size.x)
			spawn_pos.y = -margin
		1: # Bottom
			spawn_pos.x = randf_range(0, view_rect.size.x)
			spawn_pos.y = view_rect.size.y + margin
		2: # Left
			spawn_pos.x = -margin
			spawn_pos.y = randf_range(0, view_rect.size.y)
		3: # Left
			spawn_pos.x = -margin
			spawn_pos.y = randf_range(0, view_rect.size.y)
		4: # Right
			spawn_pos.x = view_rect.size.x + margin
			spawn_pos.y = randf_range(0, view_rect.size.y)
		5: # Right
			spawn_pos.x = view_rect.size.x + margin
			spawn_pos.y = randf_range(0, view_rect.size.y)
			
	return spawn_pos


# Another player called this on YOUR machine to send you an enemy
@rpc("any_peer", "reliable")
func receiveEnemy(enemyID: int):
	var sender = multiplayer.get_remote_sender_id()
	if not sender in NetworkManager.players:
		return
	var id = enemyID as Enemy.EnemyID
	if not ENEMIES.has(id):
		return
	var holder = get_tree().current_scene.find_child("EnemyNodeHolder")
	var enemy = ENEMIES[id].instantiate()
	enemy.is_sent_enemy = true
	holder.add_child(enemy)
	enemy.global_position = getRandomOffscreenPosition()

# Call this from your UI when a player spends currency to attack
func sendEnemy(enemyID: Enemy.EnemyID, target_peer_id: int):
	# RPCs can't send enums directly, cast to int
	receiveEnemy.rpc_id(target_peer_id, enemyID as int)
