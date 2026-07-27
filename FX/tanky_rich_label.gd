@tool
extends RichTextEffect
class_name RichTextTanky

var bbcode = "tanky"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# --- Parameters ---
	# drop_speed: How fast the cycle repeats
	var drop_rate = char_fx.env.get("rate", 3.0)
	
	# Create a repeating cycle using fmod
	var cycle_time = fmod(char_fx.elapsed_time, drop_rate)
	
	# Stagger the drop slightly per letter so it rolls in like a heavy platoon (optional delay)
	var stagger = char_fx.relative_index * 0.05
	var local_time = max(0.0, cycle_time - stagger)
	
	# Phase 1: Falling (First 0.4 seconds)
	var fall_duration = 0.4
	
	if local_time < fall_duration:
		var progress = local_time / fall_duration
		
		# Quadratic ease-in: simulates heavy gravity accelerating downward
		var drop_progress = progress * progress 
		
		# Start 25 pixels high and fall to 0
		char_fx.offset.y -= (1.0 - drop_progress) * 25.0
		
		# Fade in from transparent as it drops into frame
		char_fx.color.a = progress
		
	else:
		# Phase 2: Locked and Armored (Stays completely still on the baseline)
		char_fx.offset.y = 0.0
		char_fx.color.a = 1.0
		
		# Optional heavy impact micro-shake right when it lands (first 0.08 seconds of landing)
		var landing_time = local_time - fall_duration
		if landing_time < 0.08:
			var shake_step = int(landing_time * 100.0)
			char_fx.offset.x += float((shake_step * 17) % 3) - 1.5
			char_fx.offset.y += float((shake_step * 31) % 3) - 1.5

	# --- Steel Armored Color ---
	# If it has already landed or is falling, give it a heavy, armored blue-steel tint
	if local_time >= fall_duration:
		char_fx.color = Color(0.7, 0.75, 0.85, 1.0) # Solid heavy steel
	else:
		var steel_base = Color(0.7, 0.75, 0.85, 1.0)
		char_fx.color = steel_base

	return true
