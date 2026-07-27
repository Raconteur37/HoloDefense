@tool
extends RichTextEffect
class_name RichTextControlling

var bbcode = "controlling"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed = char_fx.env.get("speed", 4.0)
	
	# If you want to explicitly define where the split happens for a specific word, 
	# you can pass a custom midpoint, e.g., [controlling split=5]
	# Otherwise, we default to assuming a safe split point or fallback.
	var split_index = char_fx.env.get("split", 5) 
	
	var is_first_half = char_fx.relative_index < split_index
	
	# --- The Swap Logic ---
	var toggle = int(char_fx.elapsed_time * speed) % 2 == 0
	
	# --- The Colors ---
	var color_a = Color(1.0, 0.2, 0.6, 1.0) # Dominant Magenta
	var color_b = Color(0.1, 0.8, 1.0, 1.0) # Override Cyan
	
	if is_first_half:
		char_fx.color = color_a if toggle else color_b
	else:
		char_fx.color = color_b if toggle else color_a
		
	# Subtle sync bounce
	var offset_height = 1.5
	if is_first_half:
		char_fx.offset.y = -offset_height if toggle else offset_height
	else:
		char_fx.offset.y = offset_height if toggle else -offset_height

	return true
