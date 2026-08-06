extends TextureButton

@export var pop_scale: float = 1.5
@export var pop_duration: float = 0.3

var base_scale: Vector2 

func _ready() -> void:
	base_scale = scale 
	
	var center = size / 2.0
	
	position -= center * (Vector2.ONE - base_scale)
	
	pivot_offset = center
	
	pressed.connect(_on_button_pressed)
	
	resized.connect(func(): pivot_offset = size / 2.0)

func _on_button_pressed() -> void:
	disabled = true
	
	findButtonSound(self.name)
	
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "scale", base_scale * pop_scale, pop_duration)
	tween.tween_property(self, "modulate:a", 0.0, pop_duration)
	
	tween.chain().tween_callback(func():
		findNextProcess(self.name)

		scale = base_scale 
		modulate.a = 1.0
		disabled = false
	)

func findButtonSound(buttonName):
	match buttonName:
		
		"Challenges":
			SoundManager.playMenuButtonSound()
		"Multiplayer":
			SoundManager.playMenuButtonSound()
		"Back Button":
			SoundManager.playBackButtonSound()
		"Play Button":
			SoundManager.playMenuButtonSound()
		"Solo Button":
			SoundManager.playMenuButtonSound()
		"Turrets Button":
			SoundManager.playMenuButtonSound()
		"Shop Button":
			SoundManager.playMenuButtonSound()
		"Gallery Button":
			SoundManager.playMenuButtonSound()
		"Challenge Button":
			SoundManager.playMenuButtonSound()
		"Sandbox Button":
			SoundManager.playMenuButtonSound()

func findNextProcess(buttonName):
	match buttonName:
		
		"Back Button":
			PopupManager.clearCaptainPopups()
			get_tree().current_scene.find_child("Back Button").hide()
			get_tree().current_scene.find_child("GenericButtonHolder").show()
			get_tree().current_scene.find_child("Play Button Holder").hide()
			get_tree().current_scene.find_child("Solo Frame").hide()
			get_tree().current_scene.find_child("Multiplayer Frame").hide()
			get_tree().current_scene.find_child("Lobby Host").hide()
			if SteamManager.lobbyID != 0:
				SteamManager.leaveLobby()
				get_tree().current_scene.resetMultiplayerData()
			SoundManager.stopMusic()
		"Play Button":
			get_tree().current_scene.find_child("Play Button Holder").show()
			get_tree().current_scene.find_child("GenericButtonHolder").hide()
			get_tree().current_scene.find_child("Back Button").show()
		"Solo Button":
			PopupManager.soloNotify()
			get_tree().current_scene.find_child("Solo Frame").show()
			get_tree().current_scene.find_child("Play Button Holder").hide()
			SoundManager.playLoadoutMusic()
		"Turrets Button":
			get_tree().change_scene_to_file("res://Game Scenes/Turret Info.tscn")
		"Shop Button":
			get_tree().change_scene_to_file("res://Game Scenes/Shop.tscn")
		"Gallery Button":
			get_tree().change_scene_to_file("res://Game Scenes/Achievement Gallary.tscn")
		"Multiplayer":
			get_tree().current_scene.find_child("Multiplayer Frame").show()
			get_tree().current_scene.find_child("Play Button Holder").hide()
			get_tree().current_scene.find_child("Create Button").show()
			get_tree().current_scene.find_child("Join Button").show()
			
