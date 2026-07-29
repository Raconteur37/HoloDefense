extends CharacterBody2D

class_name Citizen

enum State {IDLE, WORKING, DELIVERING}
enum Job {NONE, GEM_SCRAPER, MATERIAL_ATOMIZER, RESEARCHER, FABRICATOR}

var hoverBox
var animationPlayer : AnimationPlayer
var sprite
var selectUI
var canvasLayer

var sex

var tutorial = false

var citizenSelectUi

@onready var citName : String 
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

var characterPortrait = null
var citPortrait = null

var frozen : bool = false

var idleTimerNotify : bool = false

var gemKeys = [
	Item.theItem.COPPER_GEM,
	Item.theItem.QUARTZ_GEM,
	Item.theItem.AMETHYST_GEM,
	Item.theItem.DIAMOND_GEM,
	Item.theItem.GALACTITE_GEM
]

var scrapKeys = [
	Item.theItem.COMMON_SCRAP,
	Item.theItem.RARE_SCRAP,
	Item.theItem.SUPER_RARE_SCRAP,
	Item.theItem.LEGENDARY_SCRAP,
	Item.theItem.UNSEEN_SCRAP
]

var gemNames = ["Copper", "Quartz", "Amethyst", "Diamond", "Galactite"]

var jobExperience : Dictionary[Job,float] = {
	Job.MATERIAL_ATOMIZER : 0,
	Job.GEM_SCRAPER : 0,
	Job.RESEARCHER : 0,
	Job.FABRICATOR : 0
}

@onready var moveSelectParticle = load("res://Particle Scenes/Citizens/Movement Line/Movement Select.tscn")
@onready var destinationParticleScene = preload("res://Particle Scenes/Citizens/Movement Line/Destination Particle.tscn")
@onready var moveLineScene = preload("res://Particle Scenes/Citizens/Movement Line/Citizen Movement Line.tscn")
@onready var popupScene = preload("res://Globals/Scene/Popup.tscn")
@onready var scrapParticle = preload("res://Particle Scenes/Citizens/Scrap Particles/scrapParticle.tscn")
@onready var area2d = $Area2D

@onready var idleTimer = $IdleTimer

func _ready() -> void:
	animationPlayer = $AnimationPlayer
	sprite = $Sprite2D
	hoverBox = $Sprite2D/HoverBox
	navAgent = $NavigationAgent2D
	selectUI = $SelectUI

	workTimer = $"Work Timer"
	deliverParticle = $"Item Delivered Particle"
	
	if randf_range(0,100) <= 50:
		sex = "male"
		sprite.texture = load("res://Textures/Citizens/Citizens_sprites/character_sprites02.png")
		citName = CitizenManager.maleNameList.pick_random()
	else:
		sex = "female"
		sprite.texture = load("res://Textures/Citizens/Citizens_sprites/character_sprites03.png")
		citName = CitizenManager.femaleNameList.pick_random()
	
	CityManager.citizenSpawned.emit(self)
	#CityManager.cityLevel = 40
	var bounds : Array = CityManager.generateBaseCitizenExperienceLevel()

	for key in jobExperience:
		jobExperience[key] = round(randf_range(bounds[0],bounds[1]) * 100) / 100

	#print(str(jobExperience))


	currentState = State.IDLE
	
	CityManager.addCitizen(self)
	

	
	if get_tree().current_scene is not CanvasLayer:
		for child in get_tree().current_scene.get_children():
			if child is CanvasLayer:
				canvasLayer = child
				break
	else:
		canvasLayer = get_tree().current_scene

func _physics_process(delta: float) -> void:
	if currentJob == Job.NONE and idleTimer.is_stopped():
		idleTimer.start()
	if not idleTimer.is_stopped() and not idleTimerNotify:
		if idleTimer.time_left <= 10 and not moving:
			idleTimerNotify = true
			PopupManager.idleWorkerPopup()
	if frozen:
		return
	if currentState == State.IDLE:
		set_collision_mask_value(5,true)
		navAgent.set_avoidance_mask_value(1,true)
	else:
		set_collision_mask_value(5,false)
		navAgent.set_avoidance_mask_value(1,false)

	if navAgent.is_navigation_finished():
		if moving:
			destinationReachedFunc()
		return

	# Normal movement path
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
	moving = false
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
	if currentJob == Job.NONE:
		updateSprite()
		scanJobArea()
		citPortrait.updatePortrait()
	else:
		updateJobTimer()

func scanJobArea():
	for area : Area2D in area2d.get_overlapping_areas():
		var areaParent = area.get_parent()
		if areaParent.is_in_group("Holo City Building"):
			if areaParent.name == "GemScraper":
				setJob(Job.GEM_SCRAPER)
				return
			if areaParent.name == "MaterialAtomizer":
				setJob(Job.MATERIAL_ATOMIZER)
				return
			if areaParent.name == "ResearchLab":
				setJob(Job.RESEARCHER)
				return
			if areaParent.name == "Fabricator":
				setJob(Job.FABRICATOR)
				return

func setJob(job : Job):
	if currentJob != job:
		if not hasJob:
			idleTimer.stop()
			idleTimerNotify = false
			currentState = State.WORKING
			hasJob = true
		currentJob = job
		updateJobTimer()
	citPortrait.updatePortrait()
	updateSprite()

func updateJobTimer():
	match currentJob:
		Job.GEM_SCRAPER:
			var jobData = CitizenManager.jobSettingsDict.get("Gem Scraper", {})
			var maxReduction = jobData.get("MaxReductionPercent")
			var progress = (jobExperience.get(Job.GEM_SCRAPER) - 1.0) / CitizenManager.maxCitizenJobLevel
			var timeSaved = (CityManager.baseScraperProductionTime * maxReduction) * progress
			#print("time saved: " + str(timeSaved))
			workTimer.wait_time = CityManager.baseScraperProductionTime - timeSaved
			if workTimer.is_stopped():
				workTimer.start()
		Job.MATERIAL_ATOMIZER:
			var jobData = CitizenManager.jobSettingsDict.get("Material Atomizer", {})
			var maxReduction = jobData.get("MaxReductionPercent")
			var progress = (jobExperience.get(Job.GEM_SCRAPER) - 1.0) / CitizenManager.maxCitizenJobLevel
			var timeSaved = (CityManager.baseAtomizerProductionTime * maxReduction) * progress
			#print("time saved: " + str(timeSaved))
			workTimer.wait_time = CityManager.baseScraperProductionTime - timeSaved
			if workTimer.is_stopped():
				workTimer.start()

func finishJob():
	match currentJob:
		Job.GEM_SCRAPER:
			var popup = popupScene.instantiate()
			canvasLayer.add_child(popup)
			popup.setPosition(self.global_position)
			
			var roll = randf_range(0.0, 100.0)
			var cumulativeWeight = 0.0
			var selectedGem = null

			for i in range(gemKeys.size()):
				var gemKey = gemKeys[i]
				cumulativeWeight += CityManager.gemChances[gemKey]
				if roll <= cumulativeWeight:
					selectedGem = gemKey
					popup.gemPopup(gemNames[i])
					addItemToInventory(selectedGem, 1)
					break
			addJobExperience(Job.GEM_SCRAPER)
			deliverItems()
			
		Job.MATERIAL_ATOMIZER:
			var particle = scrapParticle.instantiate()
			particle.setPosition(self.global_position)
			
			var roll = randf_range(0.0, 100.0)
			var cumulativeWeight = 0.0
			var selectedScrap = null

			for i in range(scrapKeys.size()):
				var scrapKey = scrapKeys[i]
				cumulativeWeight += CityManager.scrapChances[scrapKey]
				if roll <= cumulativeWeight:
					selectedScrap = scrapKey
					particle.setTexture(selectedScrap)
					addItemToInventory(selectedScrap, 1)
					break
			canvasLayer.add_child(particle)
			particle.emitting = true
			addJobExperience(Job.MATERIAL_ATOMIZER)
			deliverItems()

	CityManager.addCityXp("generate_resource")

func setWorkDestination():
	match currentJob:
		Job.GEM_SCRAPER:
			destination = CityManager.getGemScraperLocation()

		Job.MATERIAL_ATOMIZER:
			destination = CityManager.getMaterialAtomizerLocation()
			
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

func addJobExperience(job : Job):
	match job:
		
		Job.GEM_SCRAPER:
			var jobData = CitizenManager.jobSettingsDict.get("Gem Scraper", {})
			var scalingFactor = jobData.get("ScaleFactor")
			var growthRate = jobData.get("GrowthRate")
			var gain = scalingFactor * growthRate
			if jobExperience.get(job) + gain >= CitizenManager.maxCitizenJobLevel:
				jobExperience[job] = CitizenManager.maxCitizenJobLevel
			else:
				jobExperience[job] = jobExperience.get(job) + gain
		Job.MATERIAL_ATOMIZER:
			var jobData = CitizenManager.jobSettingsDict.get("Material Atomizer", {})
			var scalingFactor = jobData.get("ScaleFactor")
			var growthRate = jobData.get("GrowthRate")
			var gain = scalingFactor * growthRate
			if jobExperience.get(job) + gain >= CitizenManager.maxCitizenJobLevel:
				jobExperience[job] = CitizenManager.maxCitizenJobLevel
			else:
				jobExperience[job] = jobExperience.get(job) + gain
			#print(jobExperience)
		Job.RESEARCHER:
			var jobData = CitizenManager.jobSettingsDict.get("Researcher", {})
			var scalingFactor = jobData.get("ScaleFactor")
			var growthRate = jobData.get("GrowthRate")
			var gain = scalingFactor * growthRate
			if jobExperience.get(job) + gain >= CitizenManager.maxCitizenJobLevel:
				jobExperience[job] = CitizenManager.maxCitizenJobLevel
			else:
				jobExperience[job] = jobExperience.get(job) + gain
	updateJobTimer()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
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

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func updateSprite():
	if sex == "male":
		if currentJob == Job.NONE:
			sprite.texture = load("res://Textures/Citizens/Citizens_sprites/character_sprites02.png")
		if currentJob == Job.GEM_SCRAPER:
			sprite.texture = load("res://Textures/Citizens/Citizens_sprites/character_sprites04.png")
		if currentJob == Job.MATERIAL_ATOMIZER:
			sprite.texture = load("res://Textures/Citizens/Citizens_sprites/scrapper.png")
		if currentJob == Job.RESEARCHER:
			sprite.texture = load("res://Textures/Citizens/Citizens_sprites/reseacher.png")
		if currentJob == Job.FABRICATOR:
			sprite.texture = load("res://Textures/Citizens/Citizens_sprites/character_sprites08.png")
	if sex == "female":
		if currentJob == Job.NONE:
			sprite.texture = load("res://Textures/Citizens/Citizens_sprites/character_sprites03.png")
		if currentJob == Job.GEM_SCRAPER:
			sprite.texture = load("res://Textures/Citizens/Citizens_sprites/character_sprites05.png")
		if currentJob == Job.MATERIAL_ATOMIZER:
			sprite.texture = load("res://Textures/Citizens/Citizens_sprites/scrapper (2).png")
		if currentJob == Job.RESEARCHER:
			sprite.texture = load("res://Textures/Citizens/Citizens_sprites/researcher_female.png")
		if currentJob == Job.FABRICATOR:
			sprite.texture = load("res://Textures/Citizens/Citizens_sprites/character_sprites09.png")


func _on_idle_timer_timeout() -> void:
	if not tutorial and not moving:
		var rand = randi_range(0,100)
		if rand <= 50:
			setJob(Job.GEM_SCRAPER)
		else:
			setJob(Job.MATERIAL_ATOMIZER)
		setWorkDestination()
