extends Control

@onready var healthLabel = $Label

# This will be so we can change the sprite
func updateVisualStatus():
	pass

func _ready() -> void:
	healthLabel.text = "City Health: " + str(GameManager.cityHealth)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		GameManager.cityHealth -= body.damage
		healthLabel.text = "City Health: " + str(GameManager.cityHealth)
		EntityManager.killEnemy(null,body)
		updateVisualStatus()
