extends CanvasLayer

@onready var turretPlace = $TurretPlace
@onready var enemyPlace = $EnemyPlace
@onready var fade = $Fade
@onready var timer = $Timer

func _ready() -> void:
	pass
	#buildPreview(Turret.TurretID.ROYAL_TURRET)

func buildPreview(turret : Turret.TurretID):
	timer.start()
	fade.hide()
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

func clear():
	for child in enemyPlace.get_children():
		child.queue_free()
	for child in turretPlace.get_children():
		child.queue_free()
	fade.show()
	timer.stop()
	

func _on_timer_timeout() -> void:
	var enemy = load("res://Enemy Scenes/Basic Square.tscn").instantiate()
	enemy.global_position.y += 3500
	enemy.global_position.x -= 1000
	enemyPlace.add_child(enemy)
