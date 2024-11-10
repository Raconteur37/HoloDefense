shader_type canvas_item;

uniform vec4 neon_color = vec4(0.0, 1.0, 1.0, 1.0); // Neon color
uniform float emission_strength = 1.5; // Adjust to make the glow stronger

void fragment() {
    vec4 base_color = neon_color;
    COLOR = base_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
