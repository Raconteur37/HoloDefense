extends Control

var timer : Timer
var citizenIcon : TextureRect
var progressBar : TextureProgressBar

var generationCost : int
var generationTracker : float

func _ready():
	timer = $Timer
	citizenIcon = $CitizenIcon
	progressBar = $GenerateProgressBar

	generateCitizen(10)


func generateCitizen(genCost : int):
	generationCost = genCost
	progressBar.max_value = genCost

	timer.start()

func createCitizen():

	var citizenScene = load("res://Citizens/Basic Citizen.tscn")
	var loadedScene = citizenScene.instantiate()
	loadedScene.global_position.x += randi_range(-90,90)
	loadedScene.global_position.y += randi_range(-90,90)
	get_tree().get_first_node_in_group("CityCanvas").add_child(loadedScene)


func _on_timer_timeout() -> void:
	generationTracker += .01

	progressBar.value = generationTracker

	if generationTracker >= generationCost:
		createCitizen()
		queue_free()
