extends CanvasLayer

@onready var turretPlace = $TurretPlace
@onready var enemyPlace = $EnemyPlace

func _ready() -> void:
	buildPreview(Turret.TurretID.ZOMBIE_TURRET)

func buildPreview(turret : Turret.TurretID):
	for child in enemyPlace.get_children():
		child.queue_free()
	for child in turretPlace.get_children():
		child.queue_free()
	
	turretPlace.add_child(TurretManager.loadTurretByID(turret).instantiate())
	var enemy = load("res://Enemy Scenes/Basic Square.tscn").instantiate()
	enemy.global_position.y += 3500
	enemy.global_position.x -= 1000
	enemyPlace.add_child(enemy)


func _on_timer_timeout() -> void:
	var enemy = load("res://Enemy Scenes/Basic Square.tscn").instantiate()
	enemy.global_position.y += 3500
	enemy.global_position.x -= 1000
	enemyPlace.add_child(enemy)
