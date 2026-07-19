extends CanvasLayer

@onready var background = $Control/Background
@onready var captainTexture = $Control/Captain
@onready var speakingLabel = $"Control/Speaking Label"

@onready var main_control = $Control

var expression
var msg
var time

func _ready() -> void:
	speakingLabel.text = ""
	SoundManager.playCaptainAppear()
	#expression = "speaking"
	#msg = "Commander, a rift has been spotted in our system, there is a 22% chance it will appear while we are here."
	#time = 9
	
	show_popup()

func initiatePopup():
	buildExpression()
	if expression == "urgent":
		speakingLabel.typing_speed = 0.02
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


func show_popup():
	PopupManager.activeCaptainPopup = self
	
	var tween = create_tween()
	

	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(main_control, "scale", Vector2(0.4, 0.02), 0.1)
	

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(main_control, "scale", Vector2(0.45,0.45), 0.2)
	
	tween.finished.connect(initiatePopup)

func hide_popup():
	PopupManager.activeCaptainPopup = null
	
	SoundManager.playCaptainLeave()
	
	var tween = create_tween()
	

	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(main_control, "scale", Vector2(0.45,0.45), 0.15)
	

	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(main_control, "scale", Vector2.ZERO, 0.1)
	
	tween.finished.connect(queue_free)
