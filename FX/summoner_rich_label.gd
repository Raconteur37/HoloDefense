@tool
extends RichTextEffect
class_name RichTextSummoner

var bbcode = "summoner"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# --- Parameters ---
	# cast_rate: How fast the full spell loop repeats
	var cast_rate = char_fx.env.get("rate", 3.5)
	
	var cycle_time = fmod(char_fx.elapsed_time, cast_rate)
	
	# --- 1. The Caster (First Letter Index 0) ---
	if char_fx.relative_index == 0:
		# The caster charges up energy, pulsing in size and glowing bright arcane cyan
		var charge_pulse = (sin(cycle_time * 8.0) + 1.0) / 2.0
		
		var base_purple = Color(0.6, 0.2, 1.0, 1.0)
		var arcane_cyan = Color(0.2, 0.9, 1.0, 1.0)
		
		char_fx.color = base_purple.lerp(arcane_cyan, charge_pulse)
		
		# Slight swelling while casting
		var scale_val = 1.0 + (charge_pulse * 0.2)
		char_fx.transform = char_fx.transform.scaled(Vector2(scale_val, scale_val))
		char_fx.offset.x -= (scale_val - 1.0) * 4.0
		
		return true

	# --- 2. The Summoned Projectiles (Letters Index 1+) ---
	# Stagger the flight path so letters stream out one by one from the caster
	var delay = float(char_fx.relative_index) * 0.06
	var flight_time = max(0.0, cycle_time - delay)
	
	var travel_duration = 0.4
	
	if flight_time < travel_duration:
		# While flying out from the portal
		var progress = flight_time / travel_duration
		
		# Ease-out cubic: shoots out fast from index 0 and glides smoothly to a stop
		var ease_out = 1.0 - pow(1.0 - progress, 3.0)
		
		# Calculate distance from the first letter (moving from left to right)
		var start_offset_x = -float(char_fx.relative_index) * 12.0
		var current_offset_x = start_offset_x * (1.0 - ease_out)
		
		char_fx.offset.x += current_offset_x
		
		# Quick little arc/jump as they fly into place
		char_fx.offset.y -= sin(progress * PI) * 10.0
		
		# Fade in and glow bright cyan while materializing
		char_fx.color = Color(0.3, 0.8, 1.0, progress)
		
		# Scale down from a large burst to normal size as it locks in
		var scale_factor = 1.5 - (ease_out * 0.5)
		char_fx.transform = char_fx.transform.scaled(Vector2(scale_factor, scale_factor))
		
	else:
		# Fully summoned and locked in place on the baseline
		char_fx.offset = Vector2.ZERO
		char_fx.color = Color(0.7, 0.4, 1.0, 1.0) # Stable mystic purple

	return true
