extends CharacterBody2D


var health : float = 500

func takeDamage(damage):
	if health - damage <= 0:
		print("Lost")
	else:
		health = health - damage

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		takeDamage(body.health)
		GameManager.removeEnemyFromGame(body)
