shader_type canvas_item;

uniform float scan_speed : hint_range(0.1, 3.0) = 0.6;
uniform float scan_line_density : hint_range(10.0, 200.0) = 80.0;
uniform float scan_line_strength : hint_range(0.0, 1.0) = 0.18;
uniform float shimmer_speed : hint_range(0.0, 5.0) = 1.2;
uniform float shimmer_strength : hint_range(0.0, 1.0) = 0.12;
uniform float rgb_shift : hint_range(0.0, 0.02) = 0.004;
uniform float flicker_speed : hint_range(0.0, 10.0) = 4.0;
uniform float flicker_strength : hint_range(0.0, 0.3) = 0.04;
uniform float edge_glow_strength : hint_range(0.0, 2.0) = 0.6;
uniform vec4 holo_tint : source_color = vec4(0.22, 0.75, 1.0, 1.0);

void fragment() {
	vec2 uv = UV;

	// --- RGB chromatic shift ---
	float r = texture(TEXTURE, uv + vec2(rgb_shift, 0.0)).r;
	float g = texture(TEXTURE, uv).g;
	float b = texture(TEXTURE, uv - vec2(rgb_shift, 0.0)).b;
	float a = texture(TEXTURE, uv).a;
	vec4 col = vec4(r, g, b, a);

	// --- Horizontal scan lines (thin, dark blue) ---
	float scan_raw = sin(uv.y * scan_line_density - TIME * scan_speed * 6.28318);
	float scan_line = smoothstep(0.92, 1.0, scan_raw);
	vec3 dark_blue = vec3(0.02, 0.08, 0.25);
	col.rgb = mix(col.rgb, dark_blue, scan_line * scan_line_strength);

	// --- Moving shimmer band ---
	float band = fract(uv.y - TIME * shimmer_speed);
	float shimmer = smoothstep(0.0, 0.05, band) * smoothstep(0.15, 0.05, band);
	col.rgb += shimmer * shimmer_strength * holo_tint.rgb;

	// --- Subtle flicker ---
	float flicker = sin(TIME * flicker_speed) * sin(TIME * flicker_speed * 2.7);
	col.rgb *= 1.0 - flicker_strength * flicker;

	// --- Edge glow vignette (brighten edges) ---
	float edge_x = 1.0 - abs(uv.x * 2.0 - 1.0);
	float edge_y = 1.0 - abs(uv.y * 2.0 - 1.0);
	float edge = 1.0 - edge_x * edge_y;
	edge = pow(edge, 3.0);
	col.rgb += edge * edge_glow_strength * holo_tint.rgb * col.a;

	// --- Holo tint blend ---
	col.rgb = mix(col.rgb, col.rgb * holo_tint.rgb * 1.4, 0.25);

	COLOR = col;
}
