extends Projectile

func _on_despawn_timer_timeout() -> void:
	queue_free()

func _ready() -> void:
	super._ready()
