extends CharacterBody2D

var hoverBox
var animationPlayer
var sprite
var selectUI = null

var citName : String
const speed : float = 300
var currentJob = null

var hasJob : bool = false

var selected : bool
var moveLine = null
var destination = null
var destinationParticle = null

var destinationReached : bool = false
var moving : bool = false

var inventory : Array = []

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

func _ready() -> void:
	selected = false
	animationPlayer = $AnimationPlayer
	sprite = $Sprite2D
	hoverBox = $Sprite2D/HoverBox
	
	# Check the level of the holo generator and increase chances of prefered citizen
	# You'll be able to click on the holo generator and select the prefered citien type, and based on your city level
	# it increases the chances of getting a certain citizen with that specialty
	# every single action done by you and your citizizens increases your city level
	
	var bounds : Array = CityManager.generateBaseCitizenExperienceLevel()
	
	for key in jobExperience:
		jobExperience[key] = round(randf_range(bounds[0],bounds[1]) * 100) / 100
		
	print(jobExperience)
	
	citName = "Basic Citizen"

func _process(delta: float) -> void:
	if destination != null:
		position = position.move_toward(destination, speed * delta)
		moving = true
		updateLine()
	if moving and not destinationReached:
		if not animationPlayer.is_playing():
			animationPlayer.play("Hop")
	if destination != null and global_position == destination and not destinationReached:
		destinationReached = true
		moving = false
		destination = null
		if is_instance_valid(destinationParticle):
			destinationParticle.queue_free()
	else:
		destinationReached = false
	if selected and selectUI == null:
		var ui = load("res://Citizens/Citizen Select UI.tscn")
		var loadedUI = ui.instantiate()
		#loadedUI.buildMenu(self)
		selectUI = loadedUI
		self.add_sibling(loadedUI)
	elif not selected and selectUI != null:
		selectUI.queue_free()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if selected:
				hoverBox.visible = true
				var mouse_pos = get_viewport().get_mouse_position()
				moveToMouse(mouse_pos)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and selected:
			if selected:
				selected = false
				hoverBox.visible = false
				#Close menu
			#moving = false
			#if destinationParticle != null:
			#	destinationParticle.queue_free()
			#if selected and moveLine != null:
			#	selected = false
			#	destination = null
			#	moveLine.queue_free()
			#elif selected and moveLine == null:
			#	selected = false
			#	destination = null


func setJob(job : String):
	if currentJob != job:
		if not hasJob:
			hasJob = true
		currentJob = job
		
		match currentJob:
						
			"Gem Scraper":
				pass
				


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
