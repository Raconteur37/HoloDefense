extends Label

@onready var popupScene = $"../.."

@export var typing_speed: float = 0.04 # Seconds per character

func startTyping(new_text: String):
	text = new_text
	visible_characters = 0 
	
	var tween = create_tween()
	var total_duration = new_text.length() * typing_speed
	
	tween.tween_property(self, "visible_characters", new_text.length(), total_duration)
	
	var sound_interval = typing_speed * 3.0 
	

	while visible_characters < new_text.length():
		SoundManager.playCaptainSpeak() 

		await get_tree().create_timer(sound_interval).timeout
		

	await get_tree().create_timer(popupScene.time).timeout
	
	popupScene.hide_popup()
