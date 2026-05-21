shader_type canvas_item;

uniform float shimmer_speed : hint_range(0.0, 3.0) = 0.4;
uniform float shimmer_width : hint_range(0.01, 0.5) = 0.22;
uniform float shimmer_angle : hint_range(0.0, 6.28) = 0.6;
uniform float glow_strength : hint_range(0.0, 2.0) = 1.15;

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    if (base.a < 0.01) discard;

    // --- Creamy white-to-soft-gold gradient ---
    float grad = 1.0 - UV.y;
    vec3 top_color    = vec3(1.00, 1.00, 0.97); // pure white-cream
    vec3 mid_color    = vec3(1.00, 0.97, 0.80); // soft buttery cream
    vec3 bottom_color = vec3(0.98, 0.88, 0.60); // very light warm gold, barely tinted

    vec3 gradient;
    if (grad > 0.5) {
        gradient = mix(mid_color, top_color, (grad - 0.5) * 2.0);
    } else {
        gradient = mix(bottom_color, mid_color, grad * 2.0);
    }

    // --- Slow diagonal white glisten sweep ---
    float angle_cos = cos(shimmer_angle);
    float angle_sin = sin(shimmer_angle);
    float diag = UV.x * angle_cos + UV.y * angle_sin;
    float sweep = mod(TIME * shimmer_speed, 1.6) - 0.3;
    float shimmer = smoothstep(sweep - shimmer_width, sweep, diag)
                  * smoothstep(sweep + shimmer_width, sweep, diag);
    shimmer = pow(shimmer, 1.2);

    // --- Soft specular blob top-center ---
    float spec = pow(max(0.0, 1.0 - distance(UV, vec2(0.35, 0.18)) * 2.2), 3.0);

    // --- Very subtle edge vignette ---
    vec2 centered = UV - 0.5;
    float rim = pow(length(centered) * 1.6, 4.0) * 0.25;

    // --- Compose ---
    vec3 col = gradient;
    col += vec3(shimmer) * 0.45;
    col += vec3(spec) * 0.5;
    col -= vec3(rim);
    col *= glow_strength;
    col = clamp(col, 0.0, 1.0);

    COLOR = vec4(col * base.a, base.a);
}