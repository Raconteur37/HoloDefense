extends RigidBody2D

var shooter
var damage

func _on_despawn_timer_timeout() -> void:
	queue_free()
