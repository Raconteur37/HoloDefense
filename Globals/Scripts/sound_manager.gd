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
	var tween = create_tween()
		
	# Smoothly lower volume_db from its current value to -80.0 (total silence)
	# over the specified duration.
	tween.tween_property(musicPlayer, "volume_db", -80.0, 5)
	
	# Once the fade is complete, stop the player and reset the volume
	tween.finished.connect(func():
		musicPlayer.stop()
		musicPlayer.volume_db = 0.0 # Reset to default volume for the next song
	)

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
