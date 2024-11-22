extends Node2D

var comboTime = 1 # Time it takes before the next optive of the sound plays
var comboAmount = 0
var comboTimer

var soundPlayer

func _ready() -> void:
	comboTimer = $ComboTimer
	soundPlayer = $SoundPlayer
	comboTimer.wait_time = comboTime

func playGenericKillSound():
	comboTimer.stop()
	soundPlayer.stream = load("res://Sounds/In Game Sounds/kill.mp3")
	comboAmount += 1
	if comboAmount > 1:
		var pitchScale = 1 + (comboAmount * .1)
		soundPlayer.pitch_scale = pitchScale
	soundPlayer.play()
	comboTimer.start()


func _on_combo_timer_timeout() -> void:
	comboAmount = 0
	soundPlayer.pitch_scale = 1
