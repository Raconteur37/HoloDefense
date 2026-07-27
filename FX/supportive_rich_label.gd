@tool
extends RichTextEffect
class_name RichTextSupportive

var bbcode = "supportive"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# --- Parameters ---
	# speed: Slowed down slightly
	# freq: Dropped to 0.1 so the letters act like one continuous string
	# height: Bumped to 4.0 to give Godot enough pixels to actually animate smoothly
	var speed = char_fx.env.get("speed", 1.2)
	var freq = char_fx.env.get("freq", 0.1) 
	var height = char_fx.env.get("height", 4.0)

	# --- The Math ---
	var wave = sin((char_fx.elapsed_time * speed) - (char_fx.relative_index * freq))
	var blend = (wave + 1.0) / 2.0

	# --- 1. The Smooth Bob ---
	char_fx.offset.y -= wave * height

	# --- 2. The Lighter, Pastel Colors ---
	var light_blue = Color(0.6, 0.85, 1.0, 1.0) 
	var light_green = Color(0.6, 0.95, 0.8, 1.0)
	
	char_fx.color = light_blue.lerp(light_green, blend)

	return true
