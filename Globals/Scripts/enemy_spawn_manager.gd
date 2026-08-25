extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Preload all your scenes at the top of the script
# This stores the "template" in memory once
const NON_BOSS_ENEMIES = {
	Enemy.EnemyID.BASIC_SQUARE: preload("res://Enemy Scenes/Basic Square.tscn"),
	Enemy.EnemyID.SPEEDY_TRIANGLE: preload("res://Enemy Scenes/Speedy Triangle.tscn"),
	Enemy.EnemyID.SHOOTY_DIAMOND: preload("res://Enemy Scenes/Shooty Diamond.tscn"),
	Enemy.EnemyID.TANKY_RECTANGLE: preload("res://Enemy Scenes/Tanky Rectangle.tscn"),
	Enemy.EnemyID.PACKED_CIRCLE: preload("res://Enemy Scenes/Packed Circle.tscn"),
	Enemy.EnemyID.MINI_PACKED_CIRCLE: preload("res://Enemy Scenes/Mini Packed Circle.tscn"),
	Enemy.EnemyID.DRILLING_CONE: preload("res://Enemy Scenes/Drilling Cone.tscn")
}

const ENEMY_IDS = [
	Enemy.EnemyID.BASIC_SQUARE,
	Enemy.EnemyID.SPEEDY_TRIANGLE,
	Enemy.EnemyID.SHOOTY_DIAMOND,
	Enemy.EnemyID.HEXAGON_MOTHERSHIP,
	Enemy.EnemyID.TANKY_RECTANGLE,
	Enemy.EnemyID.PACKED_CIRCLE,
	Enemy.EnemyID.MINI_PACKED_CIRCLE,
	Enemy.EnemyID.DRILLING_CONE
]

const ENEMY_TEXTURES = {
	Enemy.EnemyID.BASIC_SQUARE: "res://Textures/Enemies/Basic Square.png",
	Enemy.EnemyID.SPEEDY_TRIANGLE: "res://Textures/Enemies/triangle_enemy.png",
	Enemy.EnemyID.SHOOTY_DIAMOND: "res://Textures/Enemies/diamond_enemy.png",
	Enemy.EnemyID.HEXAGON_MOTHERSHIP: "res://Textures/Enemies/hexagon_enemy.png",
	Enemy.EnemyID.TANKY_RECTANGLE: "res://Textures/Enemies/rectangle_enemy.png",
	Enemy.EnemyID.PACKED_CIRCLE: "res://Textures/Enemies/circle_enemy.png",
	Enemy.EnemyID.MINI_PACKED_CIRCLE: "res://Textures/Enemies/circle_enemy.png",
	Enemy.EnemyID.DRILLING_CONE: "res://Textures/Enemies/cone_enemy.png"
	}


const ENEMIES = {
	Enemy.EnemyID.BASIC_SQUARE: preload("res://Enemy Scenes/Basic Square.tscn"),
	Enemy.EnemyID.SPEEDY_TRIANGLE: preload("res://Enemy Scenes/Speedy Triangle.tscn"),
	Enemy.EnemyID.SHOOTY_DIAMOND: preload("res://Enemy Scenes/Shooty Diamond.tscn"),
	Enemy.EnemyID.HEXAGON_MOTHERSHIP: preload("res://Enemy Scenes/Hexagon Mothership.tscn"),
	Enemy.EnemyID.TANKY_RECTANGLE: preload("res://Enemy Scenes/Tanky Rectangle.tscn"),
	Enemy.EnemyID.PACKED_CIRCLE: preload("res://Enemy Scenes/Packed Circle.tscn"),
	Enemy.EnemyID.MINI_PACKED_CIRCLE: preload("res://Enemy Scenes/Mini Packed Circle.tscn"),
	Enemy.EnemyID.DRILLING_CONE: preload("res://Enemy Scenes/Drilling Cone.tscn")
}

const BOSSES = {
	Enemy.EnemyID.HEXAGON_MOTHERSHIP: preload("res://Enemy Scenes/Hexagon Mothership.tscn"),

}

func summonEnemy(enemyID : Enemy.EnemyID):
	var holder = get_tree().current_scene.find_child("EnemyNodeHolder")
	
	#print("EnemySpawnManager attempting to spawn ID: ", enemyID)
	
	if holder and ENEMIES.has(enemyID):
		#print("1. Found the preloaded scene!")
		if not SettingsManager.has_seen_enemy(enemyID):
			SettingsManager.mark_enemy_seen(enemyID)
			var enemyPopupScene = load("res://Game Scenes/EnemyInfoPopup.tscn").instantiate()
			get_tree().current_scene.add_child(enemyPopupScene)
			enemyPopupScene.buildPopup(enemyID)

		
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
		if randf_range(0,100) < 50:
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

func summonCopy(summoner,enemyID):
	var holder = get_tree().current_scene.find_child("EnemyNodeHolder")

	var enemy = ENEMIES[enemyID].instantiate()
	holder.add_child(enemy)
	enemy.global_position = summoner.global_position
	WaveManager.registerActiveEnemy(enemy)

	# Launch outward
	var angle = randf_range(0, 2 * PI)
	var direction = Vector2(cos(angle), sin(angle)).normalized()
	enemy.set_physics_process(false)

	var tween = enemy.create_tween()
	tween.tween_property(
		enemy,
		"global_position",
		summoner.global_position + direction * 120.0,
		0.6
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(func():
		enemy.set_physics_process(true)
		enemy.getDestination()
	)

func riftEvent():
	var riftScene = load("res://Game Scenes/RiftEvent.tscn").instantiate()
	var holder = get_tree().current_scene.find_child("EnemyNodeHolder")
	holder.add_child(riftScene)

func bossEvent():
	match WaveManager.currentSystem:
		
		"Similar":
			summonEnemy(Enemy.EnemyID.HEXAGON_MOTHERSHIP)

func formationEvent():
	var holder = get_tree().current_scene.find_child("EnemyNodeHolder")
	if not holder:
		return

	# Handle popups once per type so we don't spawn 100 popups at the exact same time
	var typesInFormation = [
		Enemy.EnemyID.BASIC_SQUARE, 
		Enemy.EnemyID.TANKY_RECTANGLE, 
		Enemy.EnemyID.SPEEDY_TRIANGLE, 
		Enemy.EnemyID.SHOOTY_DIAMOND
	]
	
	for type in typesInFormation:
		if not SettingsManager.has_seen_enemy(type):
			SettingsManager.mark_enemy_seen(type)
			var enemyPopupScene = load("res://Game Scenes/EnemyInfoPopup.tscn").instantiate()
			get_tree().current_scene.add_child(enemyPopupScene)
			enemyPopupScene.buildPopup(type)

	var viewRect = get_viewport().get_visible_rect()
	var viewHeight = viewRect.size.y

	# Randomly pick Left (true) or Right (false) side
	var isLeftSide = (randi() % 2 == 0)
	var margin = 60.0
	
	var currentX = -margin if isLeftSide else viewRect.size.x + margin
	var stepDir = -1.0 if isLeftSide else 1.0 

	currentX = spawnFormationGroup(Enemy.EnemyID.BASIC_SQUARE, 5, 40.0, 40.0, currentX, stepDir, viewHeight, holder)
	
	currentX = spawnFormationGroup(Enemy.EnemyID.TANKY_RECTANGLE, 2, 85.0, 70.0, currentX, stepDir, viewHeight, holder)
	
	currentX = spawnFormationGroup(Enemy.EnemyID.SPEEDY_TRIANGLE, 3, 50.0, 50.0, currentX, stepDir, viewHeight, holder)
	
	spawnFormationGroup(Enemy.EnemyID.SHOOTY_DIAMOND, 2, 100.0, 80.0, currentX, stepDir, viewHeight, holder)



func spawnFormationGroup(enemyID: Enemy.EnemyID, cols: int, ySpacing: float, xSpacing: float, startX: float, stepDir: float, viewHeight: float, holder: Node) -> float:
	var currentX = startX
	
	for col in range(cols):
		var numRows = int(viewHeight / ySpacing)
		
		var yStart = (viewHeight - ((numRows - 1) * ySpacing)) / 2.0
		
		for row in range(numRows):
			var enemy = ENEMIES[enemyID].instantiate()
			holder.add_child(enemy)
			
			enemy.global_position = Vector2(currentX, yStart + (row * ySpacing))
			WaveManager.registerActiveEnemy(enemy)
			
			if enemy.has_method("getDestination"):
				enemy.getDestination()
		
		currentX += (xSpacing * stepDir)
		
	return currentX + (30.0 * stepDir)
