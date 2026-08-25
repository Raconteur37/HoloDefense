extends Node2D

var timer : Timer
var musicPlayer : AudioStreamPlayer2D
var soundPlayer : AudioStreamPlayer2D # Assuming this is also an AudioStreamPlayer2D
var UIPlayer : AudioStreamPlayer2D

var musicOn : bool = true
var musicVolume : float = 100.0

var uiVolume : float = 100.0

const MUSIC_BUS_NAME = "Music"
const UI_BUS_NAME = "UI"

func _ready() -> void:
	timer = $Timer
	soundPlayer = $SoundPlayer
	musicPlayer = $MusicPlayer
	UIPlayer = $UIPlayer
	
	# Explicitly set the buses for pre-existing nodes just in case they aren't set in the editor
	musicPlayer.bus = MUSIC_BUS_NAME
	UIPlayer.bus = UI_BUS_NAME

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
	elif num == 2:
		UIPlayer.stream = load("res://Sounds/UI Sounds/manualGenerationTwo.wav")
	elif num == 3:
		UIPlayer.stream = load("res://Sounds/UI Sounds/manualGenerationFail.wav")
	UIPlayer.play()

func playDifficultySound(num):
	for old_sound in get_tree().get_nodes_in_group("difficulty_ui_sounds"):
		old_sound.queue_free()

	var asoundPlayer = AudioStreamPlayer2D.new()
	asoundPlayer.add_to_group("difficulty_ui_sounds")
	asoundPlayer.bus = UI_BUS_NAME # Assigning to UI bus
	
	# Load the specific difficulty sound using string formatting to save space
	var sound_path = "res://Sounds/UI Sounds/Difficulty %d Select.wav" % num
	asoundPlayer.stream = load(sound_path)
	
	# Fallback to default sound if the specific difficulty sound fails to load
	if not asoundPlayer.stream:
		asoundPlayer.stream = load("res://Sounds/UI Sounds/Button Pressed.wav")
		
	asoundPlayer.pitch_scale = 0.6
	asoundPlayer.volume_db = 1
	
	add_child(asoundPlayer)
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
	
	# Fixed indentation here
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_volume))

func setUIVolume(value: float):
	uiVolume = value
	var bus_idx = AudioServer.get_bus_index(UI_BUS_NAME)
	var linear_volume = uiVolume / 100.0
	
	if linear_volume <= 0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
	
	# Fixed indentation here
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_volume))

func playInWaveMusic():
	musicPlayer.volume_db = 0
	if musicOn and not musicPlayer.playing and not GameManager.VSmode:
		musicPlayer.stream = load("res://Sounds/Music/In Wave Song One.mp3")
		musicPlayer.play()
	if musicOn and not musicPlayer.playing and GameManager.VSmode:
		musicPlayer.volume_db = 2
		musicPlayer.stream = load("res://Sounds/Music/VS Mode.wav")
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
	# Assuming this is an in-game sound effect rather than UI, so I left bus default. 
	# Change to asoundPlayer.bus = UI_BUS_NAME if you consider it a UI sound.
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
	achievementPlayer.bus = UI_BUS_NAME # Assigning to UI bus
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

func playSlotTick():
	UIPlayer.stream = load("res://Sounds/UI Sounds/slotTick.wav")
	UIPlayer.play()

func playSlotSelect():
	# Changed from soundPlayer to dynamically spawning a UI player so it uses the UI Bus
	var asoundPlayer = AudioStreamPlayer2D.new()
	asoundPlayer.stream = load("res://Sounds/UI Sounds/slotTickSelect.wav")
	asoundPlayer.bus = UI_BUS_NAME # Assigning to UI bus
	
	add_child(asoundPlayer)
	asoundPlayer.play()
	asoundPlayer.finished.connect(asoundPlayer.queue_free)

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
	asoundPlayer.bus = UI_BUS_NAME # Assigning to UI bus
	asoundPlayer.volume_db = 5
	
	add_child(asoundPlayer)
	asoundPlayer.play()
	asoundPlayer.finished.connect(asoundPlayer.queue_free)

func playCaptainLeave():
	var asoundPlayer = AudioStreamPlayer2D.new()
	asoundPlayer.stream = load("res://Sounds/UI Sounds/commander leave.wav")
	asoundPlayer.bus = UI_BUS_NAME # Assigning to UI bus
	asoundPlayer.volume_db = 5
	
	add_child(asoundPlayer)
	asoundPlayer.play()
	asoundPlayer.finished.connect(asoundPlayer.queue_free)

func playCaptainSpeak():
	var asoundPlayer = AudioStreamPlayer2D.new()
	asoundPlayer.stream = load("res://Sounds/UI Sounds/captain speak.wav")
	asoundPlayer.bus = UI_BUS_NAME # Assigning to UI bus
	asoundPlayer.pitch_scale = randf_range(0.9, 0.95)
	asoundPlayer.volume_db = 1
	
	add_child(asoundPlayer)
	asoundPlayer.play()
	asoundPlayer.finished.connect(asoundPlayer.queue_free)

func playMenuButtonSound():
	var asoundPlayer = AudioStreamPlayer2D.new()
	asoundPlayer.stream = load("res://Sounds/UI Sounds/Button Pressed.wav")
	asoundPlayer.bus = UI_BUS_NAME # Assigning to UI bus
	asoundPlayer.pitch_scale = 1.5
	asoundPlayer.volume_db = 1.2
	
	add_child(asoundPlayer)
	asoundPlayer.play()
	asoundPlayer.finished.connect(asoundPlayer.queue_free)

func playBackButtonSound():
	var asoundPlayer = AudioStreamPlayer2D.new()
	asoundPlayer.stream = load("res://Sounds/UI Sounds/Button Pressed Reversed.wav")
	asoundPlayer.bus = UI_BUS_NAME # Assigning to UI bus
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
