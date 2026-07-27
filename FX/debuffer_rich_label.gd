@tool
extends RichTextEffect
class_name RichTextDebuffer

var bbcode = "debuffer"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# --- Parameters ---
	var speed = char_fx.env.get("speed", 2.0)
	
	# --- 1. The Slime Gradient Colors ---
	var acid_green = Color(0.4, 1.0, 0.2, 1.0)   # Bright toxic green (Highlight)
	var dark_slime = Color(0.05, 0.25, 0.08, 1.0) # Deep dark green (Shadow)
	
	# Sluggish decay wave across the letters (no movement, just color shifting)
	var wave = sin((char_fx.elapsed_time * speed) - (char_fx.relative_index * 0.3))
	var blend = (wave + 1.0) / 2.0
	
	char_fx.color = dark_slime.lerp(acid_green, blend)
	
	# Explicitly ensure no up/down or left/right movement
	char_fx.offset = Vector2.ZERO

	return true
