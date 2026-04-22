shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 10.0) = 2.0;
uniform float glow_width : hint_range(0.0, 20.0) = 2.0;

void fragment() {
    // 1. Setup local variable for pulsing (or leave as simple intensity)
    float active_intensity = glow_intensity * ((sin(TIME * 3.0) + 1.0) / 2.0 + 0.5);
    
    // 2. Sample the texture
    vec4 current_color = texture(TEXTURE, UV);
    vec2 size = TEXTURE_PIXEL_SIZE * glow_width;
    
    // 3. Detect alpha in surrounding pixels
    float alpha = 0.0;
    for(float x = -size.x; x <= size.x; x += TEXTURE_PIXEL_SIZE.x) {
        for(float y = -size.y; y <= size.y; y += TEXTURE_PIXEL_SIZE.y) {
            alpha += texture(TEXTURE, UV + vec2(x, y)).a;
        }
    }
    
    // 4. Create the glow color
    vec4 glow = vec4(glow_color.rgb, min(alpha * active_intensity, 1.0));
    
    // 5. Layer the original texture on top of the glow
    COLOR = mix(glow, current_color, current_color.a);
}