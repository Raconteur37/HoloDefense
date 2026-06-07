// super_rare_glossy.gdshader
// Attach to a ShaderMaterial on any Sprite2D or TextureRect.
// Tilt / move the mouse over the node to see the holo shimmer shift.
//
// EXPORTS you can tweak in the Inspector:
//   base_color       – the dominant rare color (default: deep violet)
//   shimmer_speed    – how fast the shimmer scrolls
//   sparkle_density  – how many sparkle points appear
//   sparkle_speed    – twinkle rate
//   rim_strength     – brightness of the rainbow edge rim
//   holo_strength    – intensity of the rainbow holo band

shader_type canvas_item;

uniform vec4  base_color     : source_color = vec4(0.22, 0.05, 0.45, 1.0);
uniform float shimmer_speed  : hint_range(0.1, 5.0)  = 1.4;
uniform float sparkle_density: hint_range(2.0, 20.0) = 8.0;
uniform float sparkle_speed  : hint_range(0.5, 10.0) = 3.0;
uniform float rim_strength   : hint_range(0.0, 2.0)  = 1.1;
uniform float holo_strength  : hint_range(0.0, 2.0)  = 0.85;

// ── Helpers ──────────────────────────────────────────────────────────────────

float hash(vec2 p) {
    p = fract(p * vec2(127.1, 311.7));
    p += dot(p, p + 19.19);
    return fract(p.x * p.y);
}

float smoothNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Convert hue (0-1) to RGB
vec3 hue2rgb(float h) {
    h = fract(h);
    float r = abs(h * 6.0 - 3.0) - 1.0;
    float g = 2.0 - abs(h * 6.0 - 2.0);
    float b = 2.0 - abs(h * 6.0 - 4.0);
    return clamp(vec3(r, g, b), 0.0, 1.0);
}

// ── Main ─────────────────────────────────────────────────────────────────────

void fragment() {
    vec2 uv = UV;
    float t  = TIME;

    // Sample the node's own texture (preserves sprite shape + alpha)
    vec4 tex = texture(TEXTURE, uv);

    // ── 1. Base deep color ───────────────────────────────────────────────────
    vec3 col = base_color.rgb;

    // ── 2. Flowing shimmer bands ─────────────────────────────────────────────
    // Diagonal noise scroll gives the "light sliding across the surface" look
    vec2 shimmerUV = uv * vec2(2.5, 1.2) + vec2(t * shimmer_speed * 0.18, t * shimmer_speed * 0.09);
    float shimmer  = smoothNoise(shimmerUV * 3.0);
    shimmer        = pow(shimmer, 2.2);          // sharpen highlights
    col           += shimmer * 0.55 * vec3(0.9, 0.75, 1.0);

    // ── 3. Rainbow holographic band ──────────────────────────────────────────
    // A diagonal sweep that shifts hue over time
    float holoAngle = uv.x * 1.6 - uv.y * 0.8 + t * shimmer_speed * 0.12;
    float holoBand  = smoothNoise(vec2(holoAngle * 2.2, 0.5));
    float hue       = fract(holoAngle * 0.4 + t * 0.08);
    vec3  rainbow   = hue2rgb(hue);
    col            += rainbow * holoBand * holo_strength * 0.6;

    // ── 4. Edge rainbow rim ──────────────────────────────────────────────────
    // Brighten pixels near the edge of the sprite for a glowing rim
    vec2  pixelSize = vec2(1.0) / vec2(textureSize(TEXTURE, 0));
    float edgeDist  = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
    float rim       = 1.0 - smoothstep(0.0, 0.12, edgeDist);
    float rimHue    = fract(uv.x * 0.7 + uv.y * 0.5 + t * 0.15);
    col            += hue2rgb(rimHue) * rim * rim_strength * tex.a;

    // ── 5. Sparkles ──────────────────────────────────────────────────────────
    vec2  sparkleUV  = floor(uv * sparkle_density) / sparkle_density;
    float sparkleID  = hash(sparkleUV);
    float sparkleT   = fract(t * sparkle_speed * (0.5 + sparkleID * 0.5) + sparkleID);
    float sparkPulse = pow(sin(sparkleT * 3.14159), 6.0);  // sharp twinkle
    // Only render sparkle if the cell "wins" the lottery
    float sparkOn    = step(0.78, hash(sparkleUV + vec2(7.3, 2.1)));
    // Position within the cell
    vec2  cellFrac   = fract(uv * sparkle_density) - 0.5;
    float starShape  = max(abs(cellFrac.x), abs(cellFrac.y));
    float crossShape = (abs(cellFrac.x) < 0.08 || abs(cellFrac.y) < 0.08) ? 1.0 : 0.0;
    float sparkMask  = crossShape * step(starShape, 0.38);
    col             += sparkMask * sparkOn * sparkPulse * 2.2 * vec3(1.0, 0.95, 1.0);

    // ── 6. Gloss specular highlight ──────────────────────────────────────────
    // A soft diagonal bright streak like light on a curved surface
    float gloss = smoothstep(0.3, 0.65,
                    uv.x * 0.55 + (1.0 - uv.y) * 0.45
                    + smoothNoise(uv * 1.5 + t * 0.06) * 0.15);
    gloss = pow(gloss, 3.5) * 0.7;
    col  += gloss * vec3(1.0, 0.92, 1.0);

    // ── 7. Vignette (darken corners for depth) ───────────────────────────────
    float vignette = uv.x * (1.0 - uv.x) * uv.y * (1.0 - uv.y) * 18.0;
    vignette       = clamp(vignette, 0.0, 1.0);
    col           *= mix(0.55, 1.0, vignette);

    // ── Output ───────────────────────────────────────────────────────────────
    // Respect the sprite's original alpha so the effect stays within the shape
    COLOR = vec4(col, tex.a * base_color.a);
}
