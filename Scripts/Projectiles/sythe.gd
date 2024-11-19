extends RigidBody2D

var shooter
var damage
var oneShotChance

func _on_despawn_timer_timeout() -> void:
	queue_free()

func _ready() -> void:
	var rand = randf_range(0,100)
	if rand <= oneShotChance:
		damage = 9999999999
