extends Control

var citizen : Citizen

var index

@onready var males = ["res://Textures/Citizens/HDportraits/Citizen Portraits09.png","res://Textures/Citizens/HDportraits/Citizen Portraits10.png",
"res://Textures/Citizens/HDportraits/Citizen Portraits11.png","res://Textures/Citizens/HDportraits/Citizen Portraits12.png"]

@onready var females = ["res://Textures/Citizens/HDportraits/Citizen Portraits05.png","res://Textures/Citizens/HDportraits/Citizen Portraits06.png",
"res://Textures/Citizens/HDportraits/Citizen Portraits07.png","res://Textures/Citizens/HDportraits/Citizen Portraits08.png"]

@onready var portrait = $CitizenPortrait
@onready var citizenIcon = $CitizenIcon


func linkCitizen(citizen,building):
	self.citizen = citizen
	if not building:
		var rand
		if citizen.sex == "male":
			rand = males.pick_random()
			citizenIcon.texture = load(rand)
		else:
			rand = females.pick_random()
			citizenIcon.texture = load(rand)
		citizen.characterPortrait = rand
	else:
		citizenIcon.texture = load(citizen.characterPortrait)

func updatePortrait():
	if citizen.currentJob == citizen.Job.NONE:
		portrait.texture_normal = load("res://Textures/Citizens/HDportraits/Citizen Portraits00.png")
	if citizen.currentJob == citizen.Job.GEM_SCRAPER:
		portrait.texture_normal = load("res://Textures/Citizens/HDportraits/Citizen Portraits03.png")
	if citizen.currentJob == citizen.Job.MATERIAL_ATOMIZER:
		portrait.texture_normal = load("res://Textures/Citizens/HDportraits/Citizen Portraits03.png")
	if citizen.currentJob == citizen.Job.RESEARCHER:
		portrait.texture_normal = load("res://Textures/Citizens/HDportraits/Citizen Portraits02.png")
	if citizen.currentJob == citizen.Job.FABRICATOR:
		portrait.texture_normal = load("res://Textures/Citizens/HDportraits/Citizen Portraits04.png")

func assignCitToFabSlot():
	get_tree().current_scene.find_child("Fabricator").assignCit(index,citizen)


func _on_citizen_portrait_pressed() -> void:
	var selectionManager = get_tree().current_scene.find_child("SelectionManager")
	
	if CityManager.assignCit:
		assignCitToFabSlot()
		return
	
	if not Input.is_key_pressed(KEY_SHIFT):
		citizen.selected = true
		if not CityManager.citizensSelected.has(citizen):
			CityManager.citizensSelected.append(citizen)
	else:
		citizen.selected = true
		if not CityManager.citizensSelected.has(citizen):
			CityManager.citizensSelected.append(citizen)


func _on_citizen_portrait_mouse_entered() -> void:
	citizen._on_area_2d_mouse_entered()


func _on_citizen_portrait_mouse_exited() -> void:
	citizen._on_area_2d_mouse_exited()
