extends RigidBody2D

var shooter
var damage
var poisonChance
var poisonTime

func _on_despawn_timer_timeout() -> void:
	queue_free()
