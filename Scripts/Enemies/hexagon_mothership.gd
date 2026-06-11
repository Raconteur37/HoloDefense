extends Enemy

class_name HexagonMothership

var summonTimer
var summonTime

var tickTimer : Timer

var enemiesToSpawn
var enemiesSpawned = 0

func _ready():
	enemyID = EnemyID.HEXAGON_MOTHERSHIP
	enemyName = EnemyManager.get_enemy_name(enemyID)
	health = EnemyManager.get_health(enemyID)
	damage = EnemyManager.get_damage(enemyID)
	type = Type.BOSS
	speed = EnemyManager.get_speed(enemyID)
	summonTime = EnemyManager.get_event_time(enemyID)
	enemiesToSpawn = EnemyManager.get_enemies_to_spawn(enemyID)
	tier = 4
	sprite = $Sprite2D
	tickTimer = $SpawnTicker
	hurtParticle = $"Basic Square Hurt"
	hitBoxArea = $HitboxArea

	summonTimer = $SummonTimer
	summonTimer.wait_time = summonTime + 15
	summonTimer.start()


func _on_summon_timer_timeout() -> void:
	if tickTimer.is_stopped():
		tickTimer.start()


func _on_spawn_ticker_timeout() -> void:
	# summon enemies
	EnemySpawnManager.mothershipSpawn(self)
	enemiesSpawned += 1
	if enemiesSpawned >= enemiesToSpawn:
		tickTimer.stop()
		enemiesSpawned = 0
