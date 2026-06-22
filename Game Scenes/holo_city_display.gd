extends Control

@onready var healthLabel = $Label

var runTime: float = 0.0
var runActive: bool = false

func startRun() -> void:
	runTime = 0.0
	runActive = true

func _process(delta: float) -> void:
	if runActive:
		runTime += delta

# This will be so we can change the sprite
func updateVisualStatus():
	pass

func _ready() -> void:
	startRun()
	healthLabel.text = "City Health: " + str(GameManager.cityHealth)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		GameManager.cityHealth -= body.damage
		healthLabel.text = "City Health: " + str(GameManager.cityHealth)
		body.queue_free()
		updateVisualStatus()
		if GameManager.cityHealth <= 0:
			runActive = false
			StatManager.elapsedTime = runTime
			get_tree().change_scene_to_file("res://Game Scenes/RewardScene.tscn")
