extends RigidBody2D

var shooter
var damage
var enemiesPierced = 0
var maxEnemyPierce = 1
var enemy
var inEnemy

func _on_despawn_timer_timeout() -> void:
	queue_free()

func _process(delta: float) -> void:
	if inEnemy:
		for x in $Area2D.get_overlapping_areas():
			if x.get_parent().is_in_group("Enemy"):
				x = x.get_parent()
				if x != enemy:
					inEnemy = false
					print("Left enemy")


func _on_area_2d_body_entered(body: Node2D) -> void:
	enemy = body
