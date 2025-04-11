extends Control

var characterTexture
var nameLabel
var destinationButton
var jobButton
var destinationText
var jobText

var holoGenText
var materialAtomizerText
var gemScraperText
var researcherText
var fabricatorText

var workProgressBar

var destinationImage
var jobImage

var citizen

func _ready() -> void:
	characterTexture = $"Background Panel/GridContainer/MarginContainer/PanelContainer/Panel/MarginContainer/TextureRect"
	nameLabel = $"Background Panel/GridContainer/LabelMarginContainer/Name Label"
	destinationButton = $"Background Panel/Location Container/MarginContainer/Destination Button"
	jobButton = $"Background Panel/Location Container/MarginContainer2/Job Button"
	destinationImage = $"Background Panel/Location Container/MarginContainer3/Destination Image"
	jobImage = $"Background Panel/Location Container/MarginContainer4/Job Image"
	destinationText = $DestinationText
	jobText = $JobText

	holoGenText = $HoloGeneratorText
	materialAtomizerText = $MaterialAtomizerText
	gemScraperText = $GemScraperText
	researcherText = $ResearcherText
	fabricatorText = $FabricatorText

	workProgressBar = $WorkProgressBar

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and visible:
			queue_free()

func buildMenu(citizenPass):
	citizen = citizenPass

	workProgressBar.max_value = citizen.workTimer.wait_time

func updateMenu():
	# A match statement that updates the item
	holoGenText.text = "Holo Generator: " + str(citizen.jobExperience.get("Holo Generator"))
	materialAtomizerText.text = "Material Atomizer: " + str(citizen.jobExperience.get("Material Atomizer"))
	gemScraperText.text = "Gem Scraper: " + str(citizen.jobExperience.get("Gem Scraper"))
	researcherText.text = "Researcher: " + str(citizen.jobExperience.get("Researcher"))
	fabricatorText.text = "Fabricator: " + str(citizen.jobExperience.get("Fabricator"))

	if not citizen.workTimer.is_stopped():
		workProgressBar.value = citizen.workTimer.wait_time - citizen.workTimer.time_left


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	updateMenu()
