extends RigidBody2D

var shooter
var damage
var poisonChance
var poisonTime
var poisonDamage
var poison = false

func _on_despawn_timer_timeout() -> void:
	queue_free()

func _ready() -> void:
	var rand = randf_range(0,100)
	if rand <= poisonChance:
		poison = true
