extends Node

var inDevMode : bool = true

func _input(event: InputEvent) -> void:

	if event is InputEventKey and event.is_pressed():

		match event.keycode:

			KEY_S:
				if inDevMode:
					EnemySpawnManager.summonEnemy(Enemy.EnemyID.BASIC_SQUARE)
			KEY_R:
				if inDevMode:
					var enemy = load("res://Enemy Scenes/Tanky Rectangle.tscn")
					enemy = enemy.instantiate()
					enemy.position = GameManager.generateRandomPosition()
					get_tree().current_scene.add_child(enemy)
			KEY_T:
				if inDevMode:
					EnemySpawnManager.summonEnemy(Enemy.EnemyID.SPEEDY_TRIANGLE)
			KEY_D:
				if inDevMode:
					EnemySpawnManager.summonEnemy(Enemy.EnemyID.SHOOTY_DIAMOND)
			KEY_H:
				if inDevMode:
					var enemy = load("res://Enemy Scenes/Hexagon Mothership.tscn")
					enemy = enemy.instantiate()
					enemy.position = GameManager.generateRandomPosition()
					get_tree().current_scene.add_child(enemy)
			KEY_W:
				WaveManager.beginNextWave()

			KEY_F1:
				#if Input.is_key_pressed(KEY_SHIFT):
				if inDevMode:
					inDevMode = false
					print("Exited dev mode")
				else:
					inDevMode = true
					print("Entered dev mode")
