extends CanvasLayer

@onready var turretPlace = $TurretPlace
@onready var enemyPlace = $EnemyPlace

func _ready() -> void:
	pass
	#buildPreview(Turret.TurretID.ZOMBIE_TURRET)

func buildPreview(turret : Turret.TurretID):
	for child in enemyPlace.get_children():
		child.queue_free()
	for child in turretPlace.get_children():
		child.queue_free()
	
	var turretActual : Turret = TurretManager.loadTurretByID(turret).instantiate()
	turretActual.preview = true
	turretPlace.add_child(turretActual)
	var enemy = load("res://Enemy Scenes/Basic Square.tscn").instantiate()
	enemy.global_position.y += 3500
	enemy.global_position.x -= 1000
	enemyPlace.add_child(enemy)


func _on_timer_timeout() -> void:
	var enemy = load("res://Enemy Scenes/Basic Square.tscn").instantiate()
	enemy.global_position.y += 3500
	enemy.global_position.x -= 1000
	enemyPlace.add_child(enemy)
