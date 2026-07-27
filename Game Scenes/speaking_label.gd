extends Label

@onready var popupScene = $"../.."

@export var typing_speed: float = 0.04 # Seconds per character
@export var max_font_size: int = 32
@export var min_font_size: int = 10

func _ready() -> void:
	resized.connect(_update_font_size)

func startTyping(new_text: String):
	text = new_text
	
	_update_font_size()
	
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

func _update_font_size() -> void:
	var current_font = get_theme_font("font")
	var current_size = max_font_size
	
	var text_width = current_font.get_string_size(text, horizontal_alignment, -1, current_size).x
	
	while text_width > size.x and current_size > min_font_size:
		current_size -= 1
		text_width = current_font.get_string_size(text, horizontal_alignment, -1, current_size).x
		
	add_theme_font_size_override("font_size", current_size)
