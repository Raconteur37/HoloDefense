@tool
extends RichTextEffect
class_name RichTextChaotic

var bbcode = "chaotic"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# --- Parameters ---
	# frenzy: Controls how fast the digital vibration shakes
	var frenzy = char_fx.env.get("frenzy", 35.0)
	
	var time_step = int(char_fx.elapsed_time * frenzy)
	
	# Unique pseudo-random seeds per character for subtle static vibration
	var seed_x = (time_step * 53) + (char_fx.relative_index * 127)
	var seed_y = (time_step * 97) + (char_fx.relative_index * 31)

	# --- 1. Subtle Digital Jitter ---
	# Kept very tight (-1 to +1 pixel) so it feels like electrical interference, not an earthquake
	var jitter_x = (float(seed_x % 20) / 10.0) - 1.0
	var jitter_y = (float(seed_y % 20) / 10.0) - 1.0
	
	char_fx.offset.x += jitter_x
	char_fx.offset.y += jitter_y

	# --- 2. Electric Purple Palette ---
	# Pulses smoothly between a deep violet and a bright electric magenta-purple
	var pulse = (sin(char_fx.elapsed_time * 6.0 + char_fx.relative_index * 0.5) + 1.0) / 2.0
	
	var deep_violet = Color(0.5, 0.1, 0.9, 1.0)   # Rich dark purple
	var electric_pink = Color(0.8, 0.3, 1.0, 1.0) # Vibrant glowing purple
	
	char_fx.color = deep_violet.lerp(electric_pink, pulse)

	return true
