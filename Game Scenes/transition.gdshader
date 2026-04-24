shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform bool turning_on = false;
// 0 = off phase, 1 = on phase (drives glow color shift)
uniform float phase : hint_range(0.0, 1.0) = 0.0;

// Hash noise for organic flicker
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float noise_flicker(float t) {
    float i = floor(t);
    float f = fract(t);
    return mix(hash(i), hash(i + 1.0), smoothstep(0.0, 1.0, f));
}

void fragment() {
    vec2 uv = UV;
    vec2 center = uv - 0.5;

    // How open the "iris" is — 0 = fully closed, 1 = fully open
    float iris = turning_on ? progress : (1.0 - progress);

    // Vertical band height collapses/expands
    float band_h = iris * 0.5;
    // Horizontal squeeze — screen pinches inward as band shrinks
    float squeeze = pow(max(iris, 0.0001), 0.4);
    float band_w = squeeze * 0.5;

    // Is this pixel inside the visible band?
    float in_y = step(abs(center.y), band_h);
    float in_x = step(abs(center.x), band_w);
    float in_band = in_y * in_x;

    if (in_band < 0.5) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    }

    // Remap UV to the visible band so content fills it properly
    vec2 band_uv;
    band_uv.x = (center.x / max(band_w, 0.0001)) * 0.5 + 0.5;
    band_uv.y = (center.y / max(band_h, 0.0001)) * 0.5 + 0.5;

    // Barrel distortion within the band
    vec2 d = band_uv - 0.5;
    float r2 = dot(d, d);
    vec2 distorted = band_uv + d * r2 * 0.18;

    // Edge vignette
    float vignette = 1.0 - smoothstep(0.35, 0.5, length(d * vec2(1.0, 1.8)));

    // Scanlines — fine horizontal lines
    float scanline = 1.0 - sin(band_uv.y * 600.0) * 0.06;

    // Phosphor glow color — shifts from warm white on turn-off to cool teal on turn-on
    vec3 off_color = vec3(0.85, 0.82, 0.72);  // warm phosphor yellow-white
    vec3 on_color  = vec3(0.55, 0.95, 0.88);  // cool CRT teal-green
    vec3 glow_col  = mix(off_color, on_color, phase);

    // Organic flicker — layered noise at different frequencies
    float t = TIME;
    float flicker = 1.0
        - noise_flicker(t * 18.0) * 0.07 * (1.0 - iris)
        - noise_flicker(t * 7.0 + 3.3) * 0.04
        - noise_flicker(t * 52.0 + 1.1) * 0.03 * (1.0 - iris);

    // Horizontal noise lines (occasional interference band)
    float interference = step(0.985, noise_flicker(t * 9.0 + band_uv.y * 2.0)) * 0.15;

    // Bright core line at center during collapse (the iconic CRT streak)
    float core = (1.0 - iris) * smoothstep(0.04, 0.0, abs(center.y)) * 2.5;
    vec3 core_col = vec3(0.9, 0.88, 0.75);

    // Compose
    float brightness = scanline * flicker * vignette - interference;
    vec3 col = glow_col * brightness + core_col * core;

    // Fade edges of the band softly
    float edge_y = smoothstep(0.0, 0.06, band_h - abs(center.y));
    float edge_x = smoothstep(0.0, 0.04, band_w - abs(center.x));

    COLOR = vec4(col * edge_y * edge_x, 1.0);
}