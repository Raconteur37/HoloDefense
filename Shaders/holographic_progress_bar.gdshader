// holographic_progress_bar.gdshader
// Attach to a ProgressBar's fill StyleBoxTexture material.
// Gives a living, animated holographic effect on top of the base fill texture.
//
// Usage:
//   var mat = ShaderMaterial.new()
//   mat.shader = preload("res://shaders/holographic_progress_bar.gdshader")
//   fill_stylebox.set_shader_material(mat)   # or assign in Inspector

shader_type canvas_item;

// ── Tuneable uniforms ───────────────────────────────────────────────────────
uniform float scan_speed      : hint_range(0.0, 4.0)  = 1.2;   // scanline scroll speed
uniform float scan_density    : hint_range(2.0, 60.0) = 22.0;  // lines per unit
uniform float scan_brightness : hint_range(0.0, 1.0)  = 0.18;  // scanline peak brightness
uniform float shimmer_speed   : hint_range(0.0, 4.0)  = 0.6;   // diagonal band speed
uniform float shimmer_count   : hint_range(1.0, 12.0) = 4.0;   // number of bands
uniform float shimmer_width   : hint_range(0.01, 0.5) = 0.12;  // band width (0-1)
uniform float shimmer_bright  : hint_range(0.0, 1.0)  = 0.30;  // band peak brightness
uniform float edge_glow       : hint_range(0.0, 2.0)  = 1.0;   // top-edge specular glow
uniform float flicker_amount  : hint_range(0.0, 1.0)  = 0.04;  // global flicker
uniform float pulse_speed     : hint_range(0.0, 4.0)  = 0.9;   // slow colour pulse
uniform vec4  holo_tint       : source_color           = vec4(0.0, 1.0, 0.94, 1.0); // base tint

// ── Noise helper (cheap 1-D hash) ──────────────────────────────────────────
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// ── Smooth noise ─────────────────────────────────────────────────────────────
float noise1(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), u);
}

void fragment() {
    vec2  uv   = UV;                          // 0..1 both axes
    float t    = TIME;

    // ── sample base texture ───────────────────────────────────────────────
    vec4 base = texture(TEXTURE, uv);

    // ── 1. horizontal scanlines (scroll downward) ─────────────────────────
    float scan_y  = uv.y * scan_density - t * scan_speed;
    float scan    = 0.5 + 0.5 * sin(scan_y * 6.28318);
    scan          = pow(max(scan, 0.0), 2.5) * scan_brightness;

    // ── 2. diagonal shimmer bands (travel left→right) ─────────────────────
    // Diagonal UV: mix x and y so bands slant ~45°
    float diag    = uv.x + uv.y * 0.5 + t * shimmer_speed * 0.1;
    // Repeat to get N bands
    float band_uv = fract(diag * shimmer_count);
    // Smooth tent wave
    float band    = 1.0 - abs(band_uv * 2.0 - 1.0);
    band          = pow(max(band - (1.0 - shimmer_width * 2.0), 0.0) / (shimmer_width * 2.0), 1.5);
    band         *= shimmer_bright;

    // ── 3. top-edge specular highlight ────────────────────────────────────
    float spec    = pow(1.0 - uv.y, 3.0) * edge_glow * 0.5;

    // ── 4. subtle colour pulse (hue shift ±few degrees) ───────────────────
    float pulse   = sin(t * pulse_speed) * 0.5 + 0.5;  // 0..1
    // Shift slightly toward blue or toward white
    vec3 pulse_col = mix(vec3(0.0, 1.0, 0.94), vec3(0.2, 0.85, 1.0), pulse * 0.3);

    // ── 5. global flicker ────────────────────────────────────────────────
    float flicker = 1.0 - flicker_amount * noise1(t * 30.0);

    // ── 6. compose ───────────────────────────────────────────────────────
    vec3 col = base.rgb;

    // Tint to holographic cyan (respects modulate for currency tiers)
    col = mix(col, col * holo_tint.rgb * 1.15, 0.55);

    // Apply scanlines — additive on the tinted colour
    col += vec3(0.7, 1.0, 1.0) * scan;

    // Apply shimmer band — slight desaturate + brighten
    col  = mix(col, col + vec3(0.6, 1.0, 1.0) * band, band);

    // Specular top-edge
    col += vec3(0.8, 1.0, 1.0) * spec;

    // Pulse subtle hue
    col = mix(col, col * pulse_col, 0.12);

    // Clamp, flicker, alpha
    col  = clamp(col, 0.0, 1.0) * flicker;

    // Preserve original alpha (for StyleBox edge softening)
    COLOR = vec4(col, base.a * holo_tint.a);
}
