extends CPUParticles2D



func _ready() -> void:
	await get_tree().create_timer(2).timeout
	gravity = Vector2(0,-200)
	emitting = true
	await get_tree().create_timer(1).timeout
	$"../CPUParticles2D2".emitting = true
	queue_free()


func _on_timer_timeout() -> void:
	$"../CPUParticles2D2".global_position.y -= 9
	
