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
	stopMusic()
	await get_tree().create_timer(1.6).timeout
	musicPlayer.volume_db = .1
	if win:
		pass
	else:
		musicPlayer.stream = load("res://Sounds/Music/Game Over.mp3")
	musicPlayer.play()
	var tween = create_tween()
	

	tween.tween_property(musicPlayer, "volume_db", 5, 2)

func playGenericKillSound():
	if soundPlayer.pitch_scale != 1:
		soundPlayer.pitch_scale = 1
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
	for old_sound in get_tree().get_nodes_in_group("difficulty_ui_sounds"):
		old_sound.queue_free()

	var asoundPlayer = AudioStreamPlayer2D.new()
	
	asoundPlayer.add_to_group("difficulty_ui_sounds")
	
	asoundPlayer.stream = load("res://Sounds/UI Sounds/Button Pressed.wav")
	asoundPlayer.pitch_scale = 0.6
	asoundPlayer.volume_db = 1
	
	add_child(asoundPlayer)

	match num:
		1:
			asoundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 1 Select.wav")
		2:
			asoundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 2 Select.wav")
		3:
			asoundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 3 Select.wav")
		4:
			asoundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 4 Select.wav")
		5:
			asoundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 5 Select.wav")
		6:
			asoundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 6 Select.wav")
		7:
			asoundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 7 Select.wav")
		8:
			asoundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 8 Select.wav")
		9:
			asoundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 9 Select.wav")
		10:
			asoundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 10 Select.wav")
		11:
			asoundPlayer.stream = load("res://Sounds/UI Sounds/Difficulty 11 Select.wav")

	asoundPlayer.finished.connect(asoundPlayer.queue_free)
	asoundPlayer.play()

func setMusicVolume(value: float):
	musicVolume = value
	var bus_idx = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	
	var linear_volume = musicVolume / 100.0
	
	if linear_volume <= 0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)

		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_volume))

func playInWaveMusic():
	musicPlayer.volume_db = 0
	if musicOn and not musicPlayer.playing:
		musicPlayer.stream = load("res://Sounds/Music/In Wave Song One.mp3")
		musicPlayer.play()

func playLoadoutMusic():
	if musicOn:
		musicPlayer.volume_db = 3
		musicPlayer.stream = load("res://Sounds/Music/Loadout.mp3")
		musicPlayer.play()

func playTurretMusic():
	if musicOn:
		musicPlayer.volume_db = 5
		musicPlayer.stream = load("res://Sounds/Music/Turret Info Music.mp3")
		musicPlayer.play()

func playPieceUnlockedSound():
	UIPlayer.stream = load("res://Sounds/UI Sounds/piece unlocked.wav")
	UIPlayer.volume_db = 5
	UIPlayer.play()

func stopMusic():
	var tween = create_tween()
	
	tween.tween_property(musicPlayer, "volume_db", -80.0, 0.5)
	
	tween.tween_callback(musicPlayer.stop)

func cityLevelUp():
	var asoundPlayer = AudioStreamPlayer2D.new()
	asoundPlayer.stream = load("res://Sounds/Hollo City Sounds/DashReady.mp3")
	asoundPlayer.volume_db = 5
	
	add_child(asoundPlayer)
	asoundPlayer.play()
	
	asoundPlayer.finished.connect(asoundPlayer.queue_free)

func enemiesIncoming():
	soundPlayer.stream = load("res://Sounds/Hollo City Sounds/enemiesIncoming.wav")
	soundPlayer.play()

func playAchievementSound():
	var achievementPlayer = AudioStreamPlayer2D.new()
	achievementPlayer.stream = load("res://Sounds/UI Sounds/achievement get.wav")
	achievementPlayer.volume_db = 5
	
	add_child(achievementPlayer)
	achievementPlayer.play()
	
	achievementPlayer.finished.connect(achievementPlayer.queue_free)

func playXpPurchaseSound():
	UIPlayer.stream = load("res://Sounds/UI Sounds/xpPurchase.wav")
	UIPlayer.pitch_scale = randf_range(0.5, 1.5)
	UIPlayer.volume_db = 5
	UIPlayer.play()
	await UIPlayer.finished
	UIPlayer.pitch_scale = 1.0
	#UIPlayer.pitch_scale = 1

func playSlotTick():
	UIPlayer.stream = load("res://Sounds/UI Sounds/slotTick.wav")
	UIPlayer.play()

func playSlotSelect():
	soundPlayer.stream = load("res://Sounds/UI Sounds/slotTickSelect.wav")
	soundPlayer.play()

func playJackPotSound():
	UIPlayer.stream = load("res://Sounds/UI Sounds/Jackpot.wav")
	UIPlayer.play()
	await get_tree().create_timer(3.3).timeout
	UIPlayer.stop()
	UIPlayer.play(1)

func _on_music_player_finished() -> void:
	timer.wait_time = randf_range(2.0, 6.0)
	timer.start()

func startTimer(time : float):
	timer.wait_time = time
	timer.start()

func _on_timer_timeout() -> void:
	playInWaveMusic()

func playStartButtonSound():
	UIPlayer.stream = load("res://Sounds/In Game Sounds/Start Run Button.wav")
	UIPlayer.play()

func playBeginRunSound():
	UIPlayer.stream = load("res://Sounds/In Game Sounds/Begin Run.wav")
	UIPlayer.play()

func playCaptainAppear():
	var asoundPlayer = AudioStreamPlayer2D.new()
	asoundPlayer.stream = load("res://Sounds/UI Sounds/commander appear.wav")
	asoundPlayer.volume_db = 5
	
	add_child(asoundPlayer)
	asoundPlayer.play()
	
	asoundPlayer.finished.connect(asoundPlayer.queue_free)

func playCaptainLeave():
	var asoundPlayer = AudioStreamPlayer2D.new()
	asoundPlayer.stream = load("res://Sounds/UI Sounds/commander leave.wav")
	asoundPlayer.volume_db = 5
	
	add_child(asoundPlayer)
	asoundPlayer.play()
	
	asoundPlayer.finished.connect(asoundPlayer.queue_free)

func playCaptainSpeak():
	var asoundPlayer = AudioStreamPlayer2D.new()
	asoundPlayer.stream = load("res://Sounds/UI Sounds/captain speak.wav")
	#asoundPlayer.pitch_scale = 0.9
	asoundPlayer.pitch_scale = randf_range(0.9,0.95)
	asoundPlayer.volume_db = 1
	
	add_child(asoundPlayer)
	asoundPlayer.play()
	
	asoundPlayer.finished.connect(asoundPlayer.queue_free)

func playMenuButtonSound():
	var asoundPlayer = AudioStreamPlayer2D.new()
	asoundPlayer.stream = load("res://Sounds/UI Sounds/Button Pressed.wav")
	asoundPlayer.pitch_scale = 1.5
	asoundPlayer.volume_db = 1.2
	
	add_child(asoundPlayer)
	asoundPlayer.play()
	
	asoundPlayer.finished.connect(asoundPlayer.queue_free)

func playBackButtonSound():
	var asoundPlayer = AudioStreamPlayer2D.new()
	asoundPlayer.stream = load("res://Sounds/UI Sounds/Button Pressed Reversed.wav")
	asoundPlayer.pitch_scale = 1.2
	asoundPlayer.volume_db = 1.2
	
	add_child(asoundPlayer)
	asoundPlayer.play()
	
	asoundPlayer.finished.connect(asoundPlayer.queue_free)

func reset():
	if not timer.is_stopped():
		timer.stop()
	soundPlayer.stop()
	musicPlayer.stop()
