shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.2, 0.3, 1.0); // enemy glow tint
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0; // push >1 to trigger bloom
uniform float pulse_speed : hint_range(0.0, 10.0) = 3.0;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.3;
uniform float rim_width : hint_range(0.0, 0.5) = 0.15;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // distance from edge of the square (0 at center, 1 at edge)
    vec2 centered = abs(UV - 0.5) * 2.0;
    float edge_dist = max(centered.x, centered.y);

    // rim glow: brighter near the edges of the square
    float rim = smoothstep(1.0 - rim_width, 1.0, edge_dist);

    // pulsing brightness over time
    float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_strength;

    vec3 base_color = tex.rgb * glow_color.rgb;
    vec3 rim_glow = glow_color.rgb * rim * glow_intensity * pulse;

    // Multiply the final calculation by Godot's built-in COLOR to apply modulate
    COLOR = vec4(base_color + rim_glow, tex.a) * COLOR;
}