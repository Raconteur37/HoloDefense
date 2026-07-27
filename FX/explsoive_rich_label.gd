@tool
extends RichTextEffect
class_name RichTextExplosive

var bbcode = "explosive"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# --- Parameters ---
	# pulse_rate: How often it pulses (e.g., every 2 seconds)
	var pulse_rate = char_fx.env.get("rate", 2.0)
	
	# --- The Synchronized Loop Math ---
	# fmod wraps elapsed_time so it loops from 0.0 to pulse_rate repeatedly
	var cycle_time = fmod(char_fx.elapsed_time, pulse_rate)
	
	# We map the first 0.6 seconds of the cycle to the pop, and the rest to resting still
	var pop_duration = 0.6
	var pulse = 0.0
	
	if cycle_time < pop_duration:
		# Normalize progress from 0.0 to 1.0 during the pop phase
		var progress = cycle_time / pop_duration
		
		# Use a sine wave mapped to half-Pi so it smoothly rises and falls in a single clean thump
		pulse = sin(progress * PI)

	# --- 1. Thermal Colors ---
	var cool_ember = Color(1.0, 0.45, 0.1, 1.0) # Deep warm orange
	var hot_core   = Color(1.0, 0.85, 0.3, 1.0) # Bright explosive core
	
	char_fx.color = cool_ember.lerp(hot_core, pulse)
	
	# --- 2. Synchronized Scale & Jump ---
	var current_scale = 1.0 + (pulse * 0.25) # Expands up by 25%
	char_fx.transform = char_fx.transform.scaled(Vector2(current_scale, current_scale))
	
	# Jump upward slightly when it pops
	char_fx.offset.y -= pulse * 4.0
	
	# Keep it horizontally centered as it scales
	char_fx.offset.x -= pulse * 3.0

	return true
