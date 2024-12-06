extends Area2D

var shooter
var damage
var enemiesPierced = 0
var maxEnemyPierce = 1
var inEnemy
var speed
var velocity

var enemiesTouched = []

func _on_despawn_timer_timeout() -> void:
	queue_free()

func _process(delta: float) -> void:
	position += velocity * delta * 5.5

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		if enemiesTouched.find(body) < 0:
			body.hit.emit(damage,shooter,body)
			enemiesTouched.append(body)
			enemiesPierced += 1
			if enemiesPierced >= maxEnemyPierce:
				queue_free()
		
