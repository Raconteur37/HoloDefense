extends Control

var citizen : CharacterBody2D
var progressBar : TextureProgressBar
var workTimer : Timer


func _ready() -> void:
	citizen = $".."
	progressBar = $WorkProgressBar
	workTimer = $"../Work Timer"
	


func refreshMenu():
	print("refreshing menu")
	
	
	
# Maybe a constant update? slowly?
func _process(delta: float) -> void:
	if citizen.currentState == Citizen.State.WORKING:
		if not workTimer.is_stopped():
			progressBar.max_value = citizen.workTimer.wait_time
			progressBar.value = citizen.workTimer.time_left
