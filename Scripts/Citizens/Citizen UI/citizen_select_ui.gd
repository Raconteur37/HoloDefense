extends Control

var characterTexture
var nameLabel
var destinationButton
var jobButton

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

#func buildMenu(citizenPass):
	#citizen = citizenPass
	#nameLabel.text = citizen.citName

func updateMenu(item,update):
	# A match statement that updates the item
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
