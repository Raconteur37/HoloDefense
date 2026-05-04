extends Projectile


func _ready() -> void:
	super._ready()  # runs parent _ready, sets contact monitor + connects signal


func _on_despawn_timer_timeout() -> void:
	queue_free()
