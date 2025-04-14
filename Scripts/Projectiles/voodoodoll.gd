extends RigidBody2D

var shooter
var damage
var curseChance
var curseTime
var curseDamageAmp
var curse = false

func _on_despawn_timer_timeout() -> void:
	queue_free()

func _ready() -> void:
	var rand = randf_range(0,100)
	if rand <= curseChance:
		curse = true
