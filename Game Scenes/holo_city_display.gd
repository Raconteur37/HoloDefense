extends Control

@onready var healthLabel = $Label

var runTime: float = 0.0
var runActive: bool = false
var timeSinceLastSave: float = 0.0
const autoSaveInterval: float = 480.0 # 8 minutes

func startRun() -> void:
	runTime = 0.0
	runActive = true

func _process(delta: float) -> void:
	if runActive:
		# Calculate real-world delta by dividing out the time scale
		var real_delta = delta
		if Engine.time_scale > 0:
			real_delta = delta / Engine.time_scale
		
		runTime += real_delta
		timeSinceLastSave += real_delta
		
		if timeSinceLastSave >= autoSaveInterval:
			XpManager.saveXpData()
			timeSinceLastSave -= autoSaveInterval

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
		WaveManager.removeActiveEnemy(body)
		EntityManager.onKill(null,body)
		updateVisualStatus()
		if GameManager.cityHealth <= 0:
			runActive = false
			StatManager.elapsedTime = runTime
			get_tree().change_scene_to_file("res://Game Scenes/RewardScene.tscn")
