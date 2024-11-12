extends RigidBody2D

var shooter
var damage
var enemiesPierced
var maxEnemyPierce

func _on_despawn_timer_timeout() -> void:
	queue_free()
