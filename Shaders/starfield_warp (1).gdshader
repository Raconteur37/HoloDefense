// starfield_warp.gdshader
// Holo Defense — End-of-Run Rewards Background
//
// Usage:
//   Attach a ShaderMaterial with this shader to a ColorRect/TextureRect.
//
// GDScript tuning:
//   var mat := $Background.material as ShaderMaterial
//   mat.set_shader_parameter("warp_speed", 1.2)
//   mat.set_shader_parameter("star_color", Color(0.85, 0.92, 1.0))

shader_type canvas_item;

uniform float warp_speed        : hint_range(0.1, 5.0)  = 1.2;
uniform float star_density      : hint_range(1.0, 6.0)  = 3.0;   // grid cells per axis per layer
uniform float streak_length     : hint_range(0.05, 0.9) = 0.55;
uniform float brightness        : hint_range(0.2, 3.0)  = 1.3;
uniform vec4  star_color        : source_color           = vec4(0.85, 0.93, 1.0, 1.0);
uniform vec4  bg_color_inner    : source_color           = vec4(0.01, 0.02, 0.12, 1.0);
uniform vec4  bg_color_outer    : source_color           = vec4(0.00, 0.00, 0.04, 1.0);
uniform float vignette_strength : hint_range(0.0, 1.5)  = 0.70;
uniform float core_glow         : hint_range(0.0, 2.0)  = 1.0;

// ── Hashing ──────────────────────────────────────────────────────────
float hash1(vec2 p) {
    p = fract(p * vec2(443.897, 441.423));
    p += dot(p, p.yx + 19.19);
    return fract((p.x + p.y) * p.x);
}

// ── One depth layer — iterates a NxN grid and accumulates every star ──
// depth: 0=close/fast/bright, 1=far/slow/dim
vec3 warp_layer(vec2 uv, float depth, float t) {
    // Centered UV so origin (0,0) = screen center
    vec2 p = uv - 0.5;   // [-0.5, 0.5]

    float N = floor(star_density * mix(2.5, 5.5, depth));
    vec2 scaled = uv * N;
    vec2 cell0 = floor(scaled);

    vec3 col = vec3(0.0);

    // Check 3x3 neighbourhood so streaks that cross cell boundaries are still drawn
    for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
        vec2 cell = cell0 + vec2(float(dx), float(dy));

        // Per-star randoms
        float h0 = hash1(cell + vec2(depth * 73.1 + 1.0, 3.7));
        float h1 = hash1(cell + vec2(17.3, depth * 91.7 + 2.0));
        float h2 = hash1(cell + vec2(depth * 43.1 + 5.0, depth * 17.5));
        float h3 = hash1(cell + vec2(depth * 29.0, depth * 61.3 + 4.0));

        float angle     = h0 * 6.2832;
        float rand_size = h1;
        float rand_phase= h2;
        float rand_temp = h3;

        // Speed: close (depth≈0) = fast, far (depth≈1) = slow
        float layer_speed = warp_speed * mix(2.2, 0.3, depth);
        float cycle = fract(rand_phase + t * layer_speed * 0.18);

        // Streak tip (leading edge, outward) and tail
        float max_r = 0.72;  // max reach from center in UV space
        float r_tip  = cycle * max_r;
        float r_tail = max(0.0, cycle - streak_length * mix(0.45, 0.15, depth)) * max_r;

        vec2 dir     = vec2(cos(angle), sin(angle));
        vec2 tip_pos = dir * r_tip;
        vec2 tail_pos= dir * r_tail;

        // Closest point on segment to current pixel
        vec2 seg     = tip_pos - tail_pos;
        float seg_len2 = dot(seg, seg) + 1e-6;
        float tt     = clamp(dot(p - tail_pos, seg) / seg_len2, 0.0, 1.0);
        float dist   = length(p - (tail_pos + seg * tt));

        // Width: close stars thicker
        float base_w = mix(0.006, 0.0015, depth);
        float width  = base_w * (0.5 + rand_size * 0.8);

        float streak_a = smoothstep(width * 2.2, 0.0, dist);

        // Tip glow dot
        float tip_dist = length(p - tip_pos);
        float tip_a    = smoothstep(width * 3.5, 0.0, tip_dist) * mix(0.9, 0.3, depth);

        // Fade: ramp in from center, ramp out near edge
        float fade = smoothstep(0.0, 0.18, cycle) * smoothstep(1.0, 0.80, cycle);

        float lum = (streak_a + tip_a) * fade * brightness * mix(1.5, 0.5, depth);

        // Color: warm whites close, blue-white far
        vec3 c;
        if (rand_temp > 0.88) {
            c = vec3(1.0, 0.87, 0.55);   // warm gold
        } else if (rand_temp > 0.65) {
            c = mix(star_color.rgb, vec3(0.65, 0.78, 1.0), depth);
        } else {
            c = mix(vec3(1.0, 1.0, 1.0), vec3(0.55, 0.70, 1.0), depth * 0.7);
        }

        col += c * lum;
    }}

    return col;
}

void fragment() {
    vec2 uv      = UV;
    vec2 centered= uv - 0.5;

    // Background radial gradient
    float bg_t = smoothstep(0.0, 0.72, length(centered) * 1.8);
    vec3 bg    = mix(bg_color_inner.rgb, bg_color_outer.rgb, bg_t);

    // ── Star layers (near → far) ───────────────────────────────────────
    vec3 stars = vec3(0.0);
    stars += warp_layer(uv, 0.92, TIME);   // far — dim, dense, slow
    stars += warp_layer(uv, 0.72, TIME);
    stars += warp_layer(uv, 0.52, TIME);
    stars += warp_layer(uv, 0.32, TIME);
    stars += warp_layer(uv, 0.14, TIME);   // close — bright, sparse, fast

    // ── Central warp glow ─────────────────────────────────────────────
    float r2    = dot(centered, centered);
    // Broad haze
    float haze  = exp(-r2 * 9.0) * 0.35 * core_glow;
    // Tight hot core
    float hotcore = exp(-r2 * 110.0) * 1.1 * core_glow;
    vec3  glow  = vec3(0.40, 0.58, 1.0) * haze
                + vec3(0.80, 0.90, 1.0) * hotcore;

    // ── Vignette ──────────────────────────────────────────────────────
    float vig   = 1.0 - smoothstep(0.28, 0.78, length(centered) * 1.6) * vignette_strength;

    vec3 final  = (bg + stars + glow) * vig;

    // Subtle HDR-style tone map so overbright whites don't clip harshly
    final = final / (final + vec3(0.6));
    final *= 1.6;   // bring it back up

    COLOR = vec4(clamp(final, 0.0, 1.0), 1.0);
}
