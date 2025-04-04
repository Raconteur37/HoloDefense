extends CanvasLayer

func _ready() -> void:
	$CPUParticles2D.emitting = true
	await get_tree().create_timer(5).timeout
	queue_free()

func setPosition(position):
	$CPUParticles2D.global_position = position
