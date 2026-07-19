shader_type canvas_item;

// Adjust these in the inspector to tune the look
uniform float chromatic_offset : hint_range(0.0, 0.05) = 0.005;
uniform float scanline_speed = 3.0;
uniform float scanline_density = 40.0;
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.15;

void fragment() {
    vec2 uv = UV;
    
    // 1. Chromatic Aberration (RGB Split)
    // We sample the red channel slightly to the right, and blue to the left
    float r = texture(TEXTURE, uv + vec2(chromatic_offset, 0.0)).r;
    float g = texture(TEXTURE, uv).g;
    float b = texture(TEXTURE, uv - vec2(chromatic_offset, 0.0)).b;
    float a = texture(TEXTURE, uv).a; // Keep original alpha so it doesn't bleed out of the UI
    
    vec4 base_color = vec4(r, g, b, a);
    
    // 2. Scrolling Diagonal Scanlines
    // (uv.x + uv.y) makes the lines diagonal instead of purely horizontal
    float scanlines = sin(((uv.x + uv.y) * scanline_density) - (TIME * scanline_speed));
    scanlines = (scanlines * 0.5) + 0.5; // Remap from [-1, 1] to [0, 1]
    
    // Darken the image where the scanlines are
    base_color.rgb -= vec3(scanlines * scanline_opacity);
    
    COLOR = base_color;
}