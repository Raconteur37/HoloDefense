@tool
extends RichTextEffect
class_name RichTextFortuitous

var bbcode = "fortuitous"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed = char_fx.env.get("speed", 5.0) 
	var flicker = char_fx.env.get("flicker", 15.0) 
	# Increased default hold time to 3 seconds so you have time to see the rainbow
	var hold_time = char_fx.env.get("hold", 3.0) 
	
	var block_length = max(1, char_fx.range.y - char_fx.range.x)
	var total_reveal_time = float(block_length) / speed
	
	var cycle_time = total_reveal_time + hold_time
	var local_time = fmod(char_fx.elapsed_time, cycle_time)
	var reveal_progress = local_time * speed
	
	if reveal_progress > char_fx.relative_index:
		# --- 1. The Revealed State ---
		var base_color = Color(1.0, 0.85, 0.3, 1.0) # Fortuitous Gold
		
		# --- 2. The Rainbow Flash ---
		if local_time >= total_reveal_time:
			var time_since_finish = local_time - total_reveal_time
			
			# Calculate the rainbow color. 
			# Multiplying time_since_finish controls how fast the colors change.
			# Subtracting relative_index makes the rainbow cascade smoothly from left to right.
			var hue = fmod((time_since_finish * 1.5) - (char_fx.relative_index * 0.1), 1.0)
			
			# Create the color using HSV (Hue, Saturation, Value, Alpha)
			# Saturation is at 0.85 so it looks vibrant but still readable
			var rainbow_color = Color.from_hsv(hue, 0.85, 1.0, 1.0)
			
			char_fx.color = rainbow_color
		else:
			# Just stay gold while the rest of the letters are still revealing
			char_fx.color = base_color
			
	else:
		# --- 3. The Obfuscation State ---
		var time_step = int(local_time * flicker)
		var chaotic_seed = (time_step * 43) + (char_fx.relative_index * 137)
		
		char_fx.glyph_index = 33 + (chaotic_seed % 75) 
		char_fx.color = Color(0.4, 0.4, 0.4, 1.0)
		
	return true
