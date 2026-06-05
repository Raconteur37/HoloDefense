shader_type canvas_item;

uniform float squeeze         : hint_range(0.0, 1.0) = 0.0;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.0;
uniform float noise_amount     : hint_range(0.0, 1.0) = 0.0;
uniform float h_glitch         : hint_range(0.0, 1.0) = 0.0;
uniform float flicker          : hint_range(0.0, 1.0) = 0.0;
uniform float brightness       : hint_range(0.0, 2.0) = 1.0;
uniform float rgb_shift        : hint_range(0.0, 0.02) = 0.0;
uniform float vignette         : hint_range(0.0, 1.0) = 0.0;
uniform vec4  tint_color        : source_color = vec4(0.1, 0.9, 0.7, 1.0);
uniform float tint_amount      : hint_range(0.0, 1.0) = 0.0;
uniform float noise_speed      : hint_range(0.0, 2.0) = 0.18; // NEW — drift speed
uniform float noise_scale      : hint_range(1.0, 16.0) = 4.0;  // NEW — blob size
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// ── Hash (still used for glitch + flicker, not for static) ──────────────
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// ── Smooth value noise — bicubic interpolated ────────────────────────────
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f); // smoothstep curve
    float a = hash(i + vec2(0.0, 0.0));
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// ── Layered FBM — 3 octaves for chunky-smooth static ────────────────────
float smooth_static(vec2 uv, float t) {
    float n  = vnoise(uv * noise_scale       + vec2(t * 0.7,  t * 0.5)) * 0.55;
           n += vnoise(uv * noise_scale * 2.1 + vec2(t * -0.4, t * 0.9)) * 0.30;
           n += vnoise(uv * noise_scale * 4.3 + vec2(t * 1.1,  t * -0.3)) * 0.15;
    return smoothstep(0.3, 0.7, n); // soft threshold — no sharp grain
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // 1. Vertical squeeze
    float sq = max(squeeze, 0.001);
    float dy = (uv.y - 0.5) / sq;
    bool outside = abs(dy) > 0.5;
    uv.y = clamp(0.5 + dy * sq, 0.0, 1.0);

    // 2. Horizontal glitch (hash-based — intentionally snappy)
    float g_seed = floor(uv.y * 30.0) + TIME * 18.0;
    float g_off  = (hash(vec2(g_seed, 0.3)) - 0.5) * h_glitch * 0.04;
    uv.x = fract(uv.x + g_off);

    // 3. RGB chromatic shift
    vec4 col;
    col.r  = texture(SCREEN_TEXTURE, uv + vec2( rgb_shift, 0.0)).r;
    col.g  = texture(SCREEN_TEXTURE, uv).g;
    col.ba = texture(SCREEN_TEXTURE, uv - vec2( rgb_shift, 0.0)).ba;

    // 4. Scanlines
    float sl = sin(SCREEN_UV.y * 600.0) * 0.5 + 0.5;
    col.rgb  = mix(col.rgb, col.rgb * 0.4, sl * scanline_strength);

    // 5. Smooth static (replaces old rand() call)
    float t = TIME * noise_speed;
    float n = smooth_static(SCREEN_UV, t);
    col.rgb  = mix(col.rgb, mix(col.rgb, vec3(n), 0.85), noise_amount);

    // 6. Flicker (hash-based — intentionally snappy)
    float fl = 1.0 - flicker * (hash(vec2(floor(TIME * 24.0), 0.0)) * 0.4);
    col.rgb *= fl;

    // 7. Holographic tint
    col.rgb = mix(col.rgb, col.rgb * tint_color.rgb * 1.4, tint_amount);

    // 8. Brightness
    col.rgb *= brightness;

    // 9. Vignette
    vec2 vu = SCREEN_UV * (1.0 - SCREEN_UV.yx);
    col.rgb *= mix(1.0, pow(vu.x * vu.y * 15.0, 0.3), vignette);

    // 10. Black bars
    if (outside) col.rgb = vec3(0.0);

    COLOR = col;
}