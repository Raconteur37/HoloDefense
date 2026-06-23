extends Node

var inDevMode : bool = false

func _input(event: InputEvent) -> void:

	if event is InputEventKey and event.is_pressed():

		match event.keycode:

			KEY_S:
				if inDevMode:
					EnemySpawnManager.summonEnemy(Enemy.EnemyID.BASIC_SQUARE)
			KEY_R:
				if inDevMode:
					EnemySpawnManager.summonEnemy(Enemy.EnemyID.TANKY_RECTANGLE)
			KEY_T:
				if inDevMode:
					EnemySpawnManager.summonEnemy(Enemy.EnemyID.SPEEDY_TRIANGLE)
			KEY_D:
				if inDevMode:
					EnemySpawnManager.summonEnemy(Enemy.EnemyID.SHOOTY_DIAMOND)
			KEY_H:
				if inDevMode:
					EnemySpawnManager.summonEnemy(Enemy.EnemyID.HEXAGON_MOTHERSHIP)
			KEY_W:
				if inDevMode:
					WaveManager.beginNextWave()
				#WaveManager.onWaveComplete()

			KEY_F1:
				#if Input.is_key_pressed(KEY_SHIFT):
				if inDevMode:
					inDevMode = false
					print("Exited dev mode")
				else:
					inDevMode = true
					print("Entered dev mode")
