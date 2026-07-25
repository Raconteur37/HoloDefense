@tool
extends RichTextEffect
class_name RichTextImpactful

var bbcode = "impactful"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# --- Parameters ---
	# speed: How fast it jumps up and down
	# height: How many pixels it moves up
	var speed = char_fx.env.get("speed", 5.0)
	var height = char_fx.env.get("height", 6.0)

	# --- The Math ---
	# Synchronized wave using only elapsed_time (no index offset)
	var wave = sin(char_fx.elapsed_time * speed)
	
	# Remap to 0.0 - 1.0 so it only jumps up from the baseline
	var pop = (wave + 1.0) / 2.0
	pop = smoothstep(0.4, 1.0, pop)

	# --- 1. Up and Down Motion ---
	# Negative Y goes UP in Godot
	char_fx.offset.y -= pop * height

	# --- 2. The Cool Orange Color ---
	var base_orange = Color(1.0, 0.45, 0.0, 1.0) # Deep solid orange
	var peak_orange = Color(1.0, 0.75, 0.2, 1.0) # Bright, glowing orange
	
	# The color naturally brightens as the letters hit the top of their jump
	char_fx.color = base_orange.lerp(peak_orange, pop)

	return true
