@tool
extends RichTextEffect
class_name RichTextSteel

var bbcode = "steel"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var base_steel = Color(0.55, 0.6, 0.65, 1.0) 
	var shine_color = Color(1.0, 1.0, 1.0, 1.0)  
	
	var speed = char_fx.env.get("speed", 3.0) 
	var frequency = char_fx.env.get("freq", 0.3)
	
	# Updated for Godot 4: relative_index perfectly scopes the wave to the BBCode block
	var wave = sin((char_fx.elapsed_time * speed) - (char_fx.relative_index * frequency))
	
	var shine_intensity = smoothstep(0.7, 1.0, wave)
	
	char_fx.color = base_steel.lerp(shine_color, shine_intensity)
	
	return true
