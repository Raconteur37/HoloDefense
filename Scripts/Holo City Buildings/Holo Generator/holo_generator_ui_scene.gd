extends Control

var citizenGenGrid : GridContainer
var storageGrid : GridContainer

func _ready():
	citizenGenGrid = $CitizenGenerateGrid
	storageGrid = $StorageGrid
	var viewport_height = get_viewport_rect().size.y
	global_position = Vector2(0,viewport_height)
	CityManager.currentHoloGeneratorUI = self


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and visible:
			visible = false
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and visible:
			if not $"Background Panel".get_global_rect().has_point(event.position):
				visible = false

func _on_generate_button_pressed() -> void:
	# Check cost and all that
	var genScene = load("res://Game Scenes/HoloCitizenGenerationScene.tscn")
	var loadedScene = genScene.instantiate()
	citizenGenGrid.add_child(loadedScene)


func _on_visibility_changed() -> void:
	if visible:
		for item in CityManager.storage.values():
			storageGrid.add_child(item)

func refresh():
	if visible:
		for item in CityManager.storage.values():
			storageGrid.add_child(item)
