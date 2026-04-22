shader_type canvas_item;

// === COLOR ===
uniform vec4 glow_color : source_color = vec4(0.2, 0.6, 1.0, 1.0);
uniform vec4 base_color : source_color = vec4(0.05, 0.05, 0.15, 1.0);

// === PULSE ===
uniform float pulse_speed : hint_range(0.1, 10.0) = 1;
uniform float pulse_min : hint_range(0.0, 1.0) = 0.2;   // Minimum glow brightness
uniform float pulse_max : hint_range(0.0, 1.0) = 1.0;   // Maximum glow brightness

// === GLOW SHAPE ===
uniform float edge_glow_width : hint_range(0.01, 0.5) = 0.15;  // How thick the glow band is from the edge
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0;     // Overall brightness multiplier
uniform float glow_falloff : hint_range(0.5, 8.0) = 2.5;       // How sharply glow fades toward center (higher = sharper)

// === INNER FILL ===
uniform float inner_alpha : hint_range(0.0, 1.0) = 0.85;       // Opacity of the panel background
uniform bool show_inner_pulse = true;   // Whether center also subtly pulses
uniform float inner_pulse_strength : hint_range(0.0, 1.0) = 0.15; // How much the center pulses

// === FLICKER (optional noise variation) ===
uniform bool enable_flicker = false;
uniform float flicker_speed : hint_range(0.1, 20.0) = 8.0;
uniform float flicker_amount : hint_range(0.0, 0.5) = 0.08;

void fragment() {
	// --- UV distance from nearest edge (0 = at edge, 1 = at center) ---
	vec2 uv = UV;
	float dist_x = min(uv.x, 1.0 - uv.x);
	float dist_y = min(uv.y, 1.0 - uv.y);
	float edge_dist = min(dist_x, dist_y); // 0 at edge, 0.5 at center

	// --- Pulse wave (smooth sine) ---
	float pulse_raw = sin(TIME * pulse_speed * 3.14159) * 0.5 + 0.5; // 0..1
	float pulse = mix(pulse_min, pulse_max, pulse_raw);

	// --- Optional flicker on top of pulse ---
	if (enable_flicker) {
		float flicker = sin(TIME * flicker_speed * 7.3) * sin(TIME * flicker_speed * 3.1);
		pulse += flicker * flicker_amount;
		pulse = clamp(pulse, 0.0, 1.0);
	}

	// --- Glow band: strongest at edge, fades inward ---
	float glow_factor = clamp(1.0 - (edge_dist / edge_glow_width), 0.0, 1.0);
	glow_factor = pow(glow_factor, glow_falloff); // Apply falloff curve

	// --- Combine glow with pulse ---
	float animated_glow = glow_factor * pulse * glow_intensity;

	// --- Inner fill pulse ---
	float fill_pulse = 1.0;
	if (show_inner_pulse) {
		fill_pulse = 1.0 + (pulse_raw - 0.5) * inner_pulse_strength;
	}

	// --- Blend base + glow ---
	vec4 fill = base_color * vec4(1.0, 1.0, 1.0, inner_alpha) * fill_pulse;
	vec4 glow = glow_color * animated_glow;

	// Additive glow on top of fill
	vec4 final_color = fill + glow;
	final_color.a = clamp(fill.a + glow.a * 0.6, 0.0, 1.0);

	// Also blend with the panel's original texture if it has one
	vec4 tex = texture(TEXTURE, UV);
	COLOR = mix(final_color, tex * final_color, tex.a * 0.3);
	COLOR.a = final_color.a;
}
