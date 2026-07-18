extends CanvasLayer

@onready var background = $Control/Background
@onready var captainTexture = $Control/Captain
@onready var speakingLabel = $"Control/Speaking Label"
@onready var animationPlayer = $AnimationPlayer

var expression
var msg
var time

func _ready() -> void:
	speakingLabel.text = ""
	animationPlayer.play("Appear")
	expression = "speaking"
	msg = "Commander, a rift has been spotted in our system, there is a 22% chance it will appear while we are here."

func initiatePopup():
	buildExpression()
	speakingLabel.startTyping(msg)
	

func buildExpression():
	match expression:
		"defualt":
			captainTexture.texture = load("res://Textures/Citizens/Captain/holo_captain0.png")
		"speaking":
			captainTexture.texture = load("res://Textures/Citizens/Captain/holo_captain1.png")
		"urgent":
			captainTexture.texture = load("res://Textures/Citizens/Captain/holo_captain2.png")
		"happy":
			captainTexture.texture = load("res://Textures/Citizens/Captain/holo_captain3.png")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Appear":
		initiatePopup()
	if anim_name == "Dissapear":
		queue_free()
