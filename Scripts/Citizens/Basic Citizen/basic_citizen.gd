extends CharacterBody2D

var hoverBox
var animationPlayer : AnimationPlayer
var sprite
var selectUI = null

var citizenSelectUi

var citName : String
const speed : float = 150
var currentJob = null

var hasJob : bool = false

var currentState : String

var workTimer : Timer = null

var selected : bool
var moveLine = null
var destination = null
var destinationParticle = null

var destinationReached : bool = false
var moving : bool = false

var inventory : Dictionary[String,int] ={}

var jobExperience : Dictionary[String,float] = {
	"Holo Generator" : 0,
	"Material Atomizer" : 0,
	"Gem Scraper" : 0,
	"Researcher" : 0,
	"Fabricator" : 0
}

@onready var moveSelectParticle = load("res://Particle Scenes/Citizens/Movement Line/Movement Select.tscn")
@onready var destinationParticleScene = preload("res://Particle Scenes/Citizens/Movement Line/Destination Particle.tscn")
@onready var moveLineScene = preload("res://Particle Scenes/Citizens/Movement Line/Citizen Movement Line.tscn")
@onready var popupScene = preload("res://Globals/Scene/Popup.tscn")

func _ready() -> void:
	selected = false
	animationPlayer = $AnimationPlayer
	sprite = $Sprite2D
	hoverBox = $Sprite2D/HoverBox

	workTimer = $"Work Timer"

	# Check the level of the holo generator and increase chances of prefered citizen
	# You'll be able to click on the holo generator and select the prefered citien type, and based on your city level
	# it increases the chances of getting a certain citizen with that specialty
	# every single action done by you and your citizizens increases your city level

	# Generate random experience for each worker based on city level

	var bounds : Array = CityManager.generateBaseCitizenExperienceLevel()

	for key in jobExperience:
		jobExperience[key] = round(randf_range(bounds[0],bounds[1]) * 100) / 100

	citName = "Basic Citizen"
	currentState = "Idle"

func _process(delta: float) -> void:
	if destination != null:
		position = position.move_toward(destination, speed * delta)
		moving = true
		updateLine()
	if moving and not destinationReached:
		if not animationPlayer.is_playing():
			animationPlayer.play("Hop")
	if destination != null and global_position == destination and not destinationReached:
		# Player has reached the destination
		destinationReached = true
		moving = false
		destination = null
		animationPlayer.stop()
		if is_instance_valid(destinationParticle):
			destinationParticle.queue_free()
		if currentState == "Delivering":
			currentState = "Idle"
			setWorkDestination()
	else:
		destinationReached = false

	if currentState == "Working":
		if workTimer.is_stopped():
			workTimer.start()

	if currentState == "Delivering":
		if not workTimer.is_stopped():
			workTimer.stop()
			destination = CityManager.getHoloGeneratorLocation()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if selected:
				if CityManager.citizensSelected.size() == 0:
					move()
				else:
					await get_tree().create_timer((.05)).timeout
					if CityManager.citizensSelected.size() == 0:
						pass
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and selected:
			deselect()

func move():
	hoverBox.visible = true
	var mouse_pos = get_viewport().get_mouse_position()
	moveToMouse(mouse_pos)
	currentState = "Idle"


func deselect():
	selected = false
	hoverBox.visible = false
	CityManager.citizensSelected.erase(self)
	#Close menu


func setJob(job : String):
	if currentJob != job:
		if not hasJob:
			currentState = "Working"
			hasJob = true

		currentJob = job

		updateJob()


func updateJob():
	match currentJob:

		"Gem Scraper":
			workTimer.wait_time = 5#round(float(10.3 / (1+jobExperience.get("Gem Scraper")*.03) * 100)) / 100


func finishJob():
	match currentJob:

		"Gem Scraper":
			currentState = "Delivering"
			var popup = popupScene.instantiate()
			popup.setPosition(self.global_position)
			popup.gemPopup("Copper")
			get_tree().current_scene.find_child("CanvasLayer").add_child(popup)
			addGemToInventory("Copper")


func setWorkDestination():
	match currentJob:

		"Gem Scraper":
			destination = CityManager.getGemScraperLocation()

func deliver():
	# Play deliver effect
	for key in inventory.keys():
		if CityManager.storage.has(key):
			CityManager.storage[key] = CityManager.storage.get(key) + inventory.get(key)
		else:
			CityManager.storage[key] = inventory.get(key)


func addGemToInventory(gemName):
	if inventory.has(gemName):
		inventory[gemName] = inventory.get(gemName) + 1
	else:
		inventory[gemName] = 1

# Rendering

func updateLine():
	moveLine.clear_points()

	var start_position = Vector2(0,0)
	var end_position = to_local(destination)
	var points = [start_position,end_position]

	moveLine.points = points

func moveToMouse(mousePos):

	var moveSelectParticleCurrent = moveSelectParticle.instantiate()
	moveSelectParticleCurrent.global_position = mousePos
	moveSelectParticleCurrent.emitting = true
	add_sibling(moveSelectParticleCurrent)

	if destinationParticle != null:
		destinationParticle.queue_free()

	var desParticleCurrent = destinationParticleScene.instantiate()
	desParticleCurrent.global_position = mousePos
	desParticleCurrent.emitting = true

	destinationParticle = desParticleCurrent

	add_sibling(desParticleCurrent)

	if moveLine != null:
		moveLine.queue_free()

	var moveLineCurrent = moveLineScene.instantiate()

	moveLineCurrent.global_position = to_local(global_position)

	# Set the positions
	var start_position = Vector2(0,0)
	var end_position = to_local(mousePos)
	var points = [start_position,end_position]

	destination = mousePos

	moveLineCurrent.points = points

	moveLine = moveLineCurrent

	add_child(moveLineCurrent)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if moving:
		animationPlayer.play("Hop")
	else:
		animationPlayer.stop()

func _on_area_2d_mouse_entered() -> void:
	hoverBox.visible = true

func _on_area_2d_mouse_exited() -> void:
	if not selected:
		hoverBox.visible = false

func _on_work_timer_timeout() -> void:
	finishJob()
