extends Area2D

var shooter
var damage
var enemiesPierced = 0
var maxEnemyPierce = 1
var inEnemy
var velocity
var speed

var enemiesTouched = []

func _on_despawn_timer_timeout() -> void:
	queue_free()

func _process(delta: float) -> void:
	position += Vector2(speed * delta,0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		if enemiesTouched.find(body) < 0:
			body.takeDamage(damage)
			enemiesTouched.append(body)
