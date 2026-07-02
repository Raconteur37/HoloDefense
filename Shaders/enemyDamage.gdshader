shader_type canvas_item;

// --- your existing flash system, untouched ---
uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

// --- glow ---
uniform vec4 glow_color : source_color = vec4(0.3, 0.9, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float rim_width : hint_range(0.01, 0.5) = 0.2;
uniform float rim_sharpness : hint_range(1.0, 8.0) = 3.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.5;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	// --- rim glow ---
	// distance from center, normalized so edges of the square = 1.0
	vec2 centered = abs(UV - 0.5) * 2.0;
	float edge_dist = max(centered.x, centered.y);
	float rim = pow(smoothstep(1.0 - rim_width, 1.0, edge_dist), rim_sharpness);

	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_strength;
	vec3 rim_glow = glow_color.rgb * rim * glow_intensity * pulse;

	// add glow on top of base texture (additive keeps the square's own color/alpha intact)
	color.rgb += rim_glow * color.a;

	// --- flash on top of everything (hit feedback should always win) ---
	if (flash_modifier > 0.0) {
		color.rgb = mix(color.rgb, flash_color.rgb, flash_modifier);
	}

	COLOR = color;
}