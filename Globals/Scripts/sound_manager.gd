extends Node2D


var timer : Timer
var musicPlayer : AudioStreamPlayer2D
var soundPlayer
var UIPlayer : AudioStreamPlayer2D

var musicOn : bool = true
var musicVolume : float = 100.0

const MUSIC_BUS_NAME = "Music"

func _ready() -> void:
	timer = $Timer
	soundPlayer = $SoundPlayer
	musicPlayer = $MusicPlayer
	UIPlayer = $UIPlayer

func playBossWaveSound():
	musicPlayer.stream = load("res://Sounds/In Game Sounds/wave10theme.mp3")
	musicPlayer.play()

func stopBossWaveSound():
	musicPlayer.stop()
	var tween = create_tween()
		

	tween.tween_property(musicPlayer, "volume_db", -80.0, 5)
	
	tween.finished.connect(func():
		musicPlayer.stop()
		musicPlayer.volume_db = 0.0
	)

func playGameOverMusic(win):
	stopActiveMusic()
	await get_tree().create_timer(1.6).timeout
	musicPlayer.volume_db = .1
	if win:
		pass
	else:
		musicPlayer.stream = load("res://Sounds/Music/GameOverNotBad.mp3")
	musicPlayer.play()
	var tween = create_tween()
	

	tween.tween_property(musicPlayer, "volume_db", 5, 2)

func playGenericKillSound():
	soundPlayer.stream = load("res://Sounds/In Game Sounds/kill.wav")
	soundPlayer.play()

func playManualGenSound(num):
	if num == 1:
		UIPlayer.stream = load("res://Sounds/UI Sounds/manualGenerationOne.wav")
	if num == 2:
		UIPlayer.stream = load("res://Sounds/UI Sounds/manualGenerationTwo.wav")
	if num == 3:
		UIPlayer.stream = load("res://Sounds/UI Sounds/manualGenerationFail.wav")
	UIPlayer.play()

func playDifficultySound(num):
	match num:
		
		1:
			soundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 1 Select.wav")
		2:
			soundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 2 Select.wav")
		3:
			soundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 3 Select.wav")
		4:
			soundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 4 Select.wav")
		5:
			soundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 5 Select.wav")
		6:
			soundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 6 Select.wav")
		7:
			soundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 7 Select.wav")
		8:
			soundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 8 Select.wav")
		9:
			soundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 9 Select.wav")
		10:
			soundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 10 Select.wav")
		11:
			soundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 11 Select.wav")

	soundPlayer.play()

func setMusicVolume(value: float):
	musicVolume = value
	var bus_idx = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	
	# Convert 0-100 to 0.0-1.0
	var linear_volume = musicVolume / 100.0
	
	if linear_volume <= 0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		# Use linear_to_db for smooth, natural volume scaling
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_volume))

func playInWaveMusic():
	musicPlayer.volume_db = 0
	if musicOn and not musicPlayer.playing:
		musicPlayer.stream = load("res://Sounds/Music/In Wave Song One.mp3")
		musicPlayer.play()

func playLoadoutMusic():
	if musicOn and not musicPlayer.playing:
		musicPlayer.volume_db = 5
		musicPlayer.stream = load("res://Sounds/Music/Loudout Menu Music.mp3")
		musicPlayer.play()

func playPieceUnlockedSound():
	UIPlayer.stream = load("res://Sounds/UI Sounds/piece unlocked.wav")
	UIPlayer.volume_db = 5
	UIPlayer.play()

func stopLoadoutMusic():
	var tween = create_tween()
	
	tween.tween_property(musicPlayer, "volume_db", -80.0, 5)
	
	tween.tween_callback(musicPlayer.stop)

func stopActiveMusic():
	var tween = create_tween()
	
	tween.tween_property(musicPlayer, "volume_db", -80.0, 1)
	
	tween.tween_callback(musicPlayer.stop)

func cityLevelUp():
	soundPlayer.stream = load("res://Sounds/Hollo City Sounds/DashReady.mp3")
	soundPlayer.play()

func enemiesIncoming():
	soundPlayer.stream = load("res://Sounds/Hollo City Sounds/enemiesIncoming.wav")
	soundPlayer.play()


func _on_music_player_finished() -> void:
	timer.wait_time = randf_range(2.0, 6.0)
	timer.start()

func startTimer(time : float):
	timer.wait_time = time
	timer.start()

func _on_timer_timeout() -> void:
	playInWaveMusic()

func stopMusic():
	musicPlayer.stop()

func reset():
	if not timer.is_stopped():
		timer.stop()
	soundPlayer.stop()
	musicPlayer.stop()
