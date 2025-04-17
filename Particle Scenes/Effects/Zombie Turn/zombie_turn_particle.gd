extends CanvasLayer

func _ready() -> void:
	$ZombieTurnParticle.emitting = true
	await get_tree().create_timer(2).timeout
	queue_free()

func setPosition(position):
	$ZombieTurnParticle.global_position = position
