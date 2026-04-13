extends CharacterBody2D

class_name Citizen

enum State {IDLE, WORKING, DELIVERING}
enum Job {NONE, GEM_SCRAPER, MATERIAL_ATOMIZER, RESEARCHER, FABRICATOR}

var hoverBox
var animationPlayer : AnimationPlayer
var sprite
var selectUI

var citizenSelectUi

var citName : String
@export var speed : float = 200
var currentJob : Job = Job.NONE

var hasJob : bool = false

var currentState : State

var workTimer : Timer = null

var selected : bool = false:
	set(value):
		selected = value
		if is_node_ready():
			hoverBox.visible = value

var moveLine = null
var destination = null
var destinationParticle = null

var destinationReached : bool = false
var moving : bool = false

var lastPosition : Vector2
var timeSinceMove : float = 0
var moveThresh : float = 1  # how far the unit must move to be moving
var stuckTimeout : float = 1  # how many seconds before it's considered stuck

var deliverParticle : CPUParticles2D

var navAgent : NavigationAgent2D

var inventory : Dictionary = {} # This holds an enum then int like so [enum,int]


var jobExperience : Dictionary[String,float] = {
	"Material Atomizer" : 0,
	"Gem Scraper" : 0,
	"Researcher" : 0,
	"Fabricator" : 0
}

@onready var moveSelectParticle = load("res://Particle Scenes/Citizens/Movement Line/Movement Select.tscn")
@onready var destinationParticleScene = preload("res://Particle Scenes/Citizens/Movement Line/Destination Particle.tscn")
@onready var moveLineScene = preload("res://Particle Scenes/Citizens/Movement Line/Citizen Movement Line.tscn")
@onready var popupScene = preload("res://Globals/Scene/Popup.tscn")
@onready var ui = $SelectUI

func _ready() -> void:
	animationPlayer = $AnimationPlayer
	sprite = $Sprite2D
	hoverBox = $Sprite2D/HoverBox
	navAgent = $NavigationAgent2D
	selectUI = $SelectUI

	workTimer = $"Work Timer"
	deliverParticle = $"Item Delivered Particle"
	
	CityManager.citizenSpawned.emit(self)

	var bounds : Array = CityManager.generateBaseCitizenExperienceLevel()

	for key in jobExperience:
		jobExperience[key] = round(randf_range(bounds[0],bounds[1]) * 100) / 100

	citName = "Basic Citizen"
	currentState = State.IDLE

func _physics_process(delta: float) -> void:
	if currentState == State.IDLE:
		set_collision_mask_value(5,true)
		navAgent.set_avoidance_mask_value(1,true)
	else:
		set_collision_mask_value(5,false)
		navAgent.set_avoidance_mask_value(1,false)

	if navAgent.is_navigation_finished():
		if currentState == State.WORKING:
			if workTimer.is_stopped():
				workTimer.start()
		
		destinationReachedFunc()
		return

	var currentPos = global_position
	var nextPosition = navAgent.get_next_path_position()
	var newVelocity = currentPos.direction_to(nextPosition) * speed

	navAgent.set_velocity(newVelocity)
	move_and_slide()
	moving = true

	if is_instance_valid(moveLine):
		updateLine()

	# Stuck Mechanic
	var distance_moved = global_position.distance_to(lastPosition)
	if distance_moved > moveThresh:
		timeSinceMove = 0.0
		lastPosition = global_position
	else:
		timeSinceMove += delta

	if timeSinceMove >= stuckTimeout:
		destinationReachedFunc()

	if not navAgent.is_navigation_finished():
		if not animationPlayer.is_playing():
			animationPlayer.play("Hop")

func deselect():
	selected = false
	hoverBox.visible = false
	CityManager.citizensSelected.erase(self)

func destinationReachedFunc():
	navAgent.target_position = global_position
	animationPlayer.stop()
	if is_instance_valid(destinationParticle):
		destinationParticle.queue_free()
	if is_instance_valid(moveLine):
		moveLine.queue_free()
	if currentState == State.DELIVERING:
		currentState = State.IDLE
		setWorkDestination()
	timeSinceMove = 0

func setJob(job : Job):
	if currentJob != job:
		if not hasJob:
			currentState = State.WORKING
			hasJob = true
		currentJob = job
		updateJob()

func updateJob():
	match currentJob:
		Job.GEM_SCRAPER:
			workTimer.wait_time = .5

func finishJob():
	match currentJob:
		Job.GEM_SCRAPER:
			var popup = popupScene.instantiate()
			popup.setPosition(self.global_position)
			var randGem = randi_range(1,100)
			if randGem >= 1 and randGem <= 50:
				popup.gemPopup("Copper")
				addItemToInventory(Item.theItem.COPPER_GEM,1)
			elif randGem >= 51 and randGem <= 70:
				popup.gemPopup("Quartz")
				addItemToInventory(Item.theItem.QUARTZ_GEM,1)
			elif randGem >= 71 and randGem <= 85:
				popup.gemPopup("Amethyst")
				addItemToInventory(Item.theItem.AMETHYST_GEM,1)
			elif randGem >= 86 and randGem <= 96:
				addItemToInventory(Item.theItem.DIAMOND_GEM,1)
			
			get_tree().current_scene.find_child("CanvasLayer").add_child(popup)
			deliverItems()

func setWorkDestination():
	match currentJob:
		Job.GEM_SCRAPER:
			destination = CityManager.getGemScraperLocation()
			navAgent.target_position = destination

func deliverItems():
	currentState = State.DELIVERING
	workTimer.stop()
	destination = CityManager.getHoloGeneratorLocation()
	navAgent.target_position = destination

func finishDelivery():
	deliverParticle.emitting = true
	for item in inventory.keys():
		CityManager.addItem(item)
	inventory.clear()

func addItemToInventory(item,amount):
	if inventory.has(item):
		inventory[item] += amount
	else:
		inventory[item] = amount

func updateLine():
	moveLine.clear_points()
	var start_position = Vector2(0,0)
	var end_position = to_local(destination)
	var points = [start_position,end_position]
	moveLine.points = points

# CHANGED: Now accepts a target position directly
func moveToMouse(targetPos: Vector2 = get_global_mouse_position()):
	currentState = State.IDLE
	
	var moveSelectParticleCurrent = moveSelectParticle.instantiate()
	moveSelectParticleCurrent.global_position = targetPos
	moveSelectParticleCurrent.emitting = true
	add_sibling(moveSelectParticleCurrent)

	if destinationParticle != null:
		destinationParticle.queue_free()

	var desParticleCurrent = destinationParticleScene.instantiate()
	desParticleCurrent.global_position = targetPos
	desParticleCurrent.emitting = true
	destinationParticle = desParticleCurrent
	add_sibling(desParticleCurrent)

	if moveLine != null:
		moveLine.queue_free()

	var moveLineCurrent = moveLineScene.instantiate()
	moveLineCurrent.global_position = to_local(global_position)

	var start_position = Vector2(0,0)
	var end_position = to_local(targetPos)
	var points = [start_position,end_position]

	destination = targetPos
	navAgent.target_position = destination
	moveLineCurrent.points = points
	moveLine = moveLineCurrent
	add_child(moveLineCurrent)

func openMenu():
	ui.show()
	ui.refreshMenu()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if moving:
		animationPlayer.play("Hop")
	else:
		animationPlayer.stop()

func _on_area_2d_mouse_entered() -> void:
	hoverBox.visible = true
	selectUI.show()

func _on_area_2d_mouse_exited() -> void:
	if not selected:
		hoverBox.visible = false
	selectUI.hide()

func _on_work_timer_timeout() -> void:
	finishJob()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
