extends Control

var stage = 0
var stageActive = false

var inputActive = false

var currentPopup

@onready var skipButtonContainer = $SkipButtonContainer
@onready var commanderPopup = preload("res://Game Scenes/CommanderPopup.tscn")

@onready var animationPlayer = $AnimationPlayer

func _ready() -> void:
	skipButtonContainer.hide()

func _input(event: InputEvent) -> void:

	if event is InputEventKey and event.is_pressed() and inputActive:
		
		stageActive = false
		stage += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stage == 0 and not stageActive:
		stageActive = true
		activatePopup("Welcome Commander, it's been a while...","speaking")
	if stage == 1 and not stageActive:
		stageActive = true
		activatePopup("You've been offline for eons, but our goal of reaching the edge of the universe hasn't subsided.","speaking")
	if stage == 2 and not stageActive:
		stageActive = true
		activatePopup("Did the systems restore your memory? If not, I can briefly help you remember your task.","speaking")
	if stage == 3 and not stageActive:
		stageActive = true
		activatePopup("Understandable, booting up the simulation now...","happy")

func checkProgress():
	pass

func activatePopup(msg,expression):
	inputActive = false
	if currentPopup != null:
		currentPopup.queue_free()
	var commandPopup = commanderPopup.instantiate()
	add_child(commandPopup)
	var viewport_size = get_viewport_rect().size
	commandPopup.get_child(0).global_position = viewport_size / 2.0
	commandPopup.get_child(0).global_position.x -= 225
	commandPopup.get_child(0).global_position.y -= 100
	currentPopup = commandPopup
	commandPopup.msg = msg
	commandPopup.expression = expression
	commandPopup.time = 999
	await get_tree().create_timer(3).timeout
	if stage == 2:
		skipButtonContainer.show()
		inputActive = false
	else:
		inputActive = true


func _on_skip_pressed() -> void:
	#SettingsManager.mark_tutorial_done()
	activatePopup("Understood, we await your orders.","happy")
	skipButtonContainer.hide()
	await get_tree().create_timer(1).timeout
	animationPlayer.play("FadeOut")

func _on_continue_pressed() -> void:
	skipButtonContainer.hide()
	stage += 1
	stageActive = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeOut":
		get_tree().change_scene_to_file("res://Game Scenes/Main Menu.tscn")
