extends Node2D

var visualBox

const speed = 300

var selected
var moveLine = null
var destination = null
var destinationParticle = null

var destinationReached : bool = false


@onready var moveSelectParticle = load("res://Particle Scenes/Citizens/Movement Line/Movement Select.tscn")
@onready var destinationParticleScene = preload("res://Particle Scenes/Citizens/Movement Line/Destination Particle.tscn")
@onready var moveLineScene = preload("res://Particle Scenes/Citizens/Movement Line/Citizen Movement Line.tscn")

func _ready() -> void:
	selected = false
	visualBox = $Sprite2D/Area2D/VisualBox

func _process(delta: float) -> void:
	if destination != null:
		position = position.move_toward(destination, speed * delta)
		updateLine()
	if destination != null and global_position == destination and not destinationReached:
		destinationReached = true
		if is_instance_valid(destinationParticle):
			destinationParticle.queue_free()
	else:
		destinationReached = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if selected:
				var mouse_pos = get_viewport().get_mouse_position()
				moveToMouse(mouse_pos)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if destinationParticle != null:
				destinationParticle.queue_free()
			if selected and moveLine != null:
				selected = false
				destination = null
				moveLine.queue_free()
			elif selected and moveLine == null:
				selected = false
				destination = null

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
