extends Node2D


var comboTimer
var musicPlayer
var soundPlayer

func _ready() -> void:
	comboTimer = $ComboTimer
	soundPlayer = $SoundPlayer
	musicPlayer = $MusicPlayer

func playBossWaveSound():
	musicPlayer.stream = load("res://Sounds/In Game Sounds/wave10theme.mp3")
	musicPlayer.play()

func stopBossWaveSound():
	musicPlayer.stop()

func playGenericKillSound():
	comboTimer.stop()
	soundPlayer.stream = load("res://Sounds/In Game Sounds/kill.wav")
	soundPlayer.play()
	comboTimer.start()

func cityLevelUp():
	soundPlayer.stream = load("res://Sounds/Hollo City Sounds/DashReady.mp3")
	soundPlayer.play()

func enemiesIncoming():
	soundPlayer.stream = load("res://Sounds/Hollo City Sounds/enemiesIncoming.wav")
	soundPlayer.play()

func _on_combo_timer_timeout() -> void:
	soundPlayer.pitch_scale = 1
