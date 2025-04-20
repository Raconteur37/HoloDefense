extends CanvasLayer

func _ready() -> void:
	$Heal.emitting = true
	await get_tree().create_timer(2).timeout
	queue_free()


func setPosition(position):
	$Heal.global_position = position
