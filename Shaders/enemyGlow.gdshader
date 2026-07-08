shader_type canvas_item;

// --- Core Sprite Tint ---
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// --- Flash System ---
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

// --- Glow System ---
uniform vec4 glow_color : source_color = vec4(0.3, 0.9, 1.0, 1.0);
uniform float glow_thickness : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 4.0;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);
    
    // Multiply the white sprite by the tint color to dye it
    base_color.rgb *= tint_color.rgb;
    
    // 1. Calculate an animated pulse multiplier
    float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_strength;
    
    // 2. Read neighboring pixels to find the true edges of the sprite drawing
    vec2 size = TEXTURE_PIXEL_SIZE * glow_thickness;
    float outline = texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
    outline += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
    outline += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
    
    // Clamp the outline so it doesn't exceed 1.0 transparency
    outline = min(outline, 1.0);
    
    // 3. Create the glowing outer rim, blending it onto the empty space around the sprite
    vec4 final_color = mix(base_color, vec4(glow_color.rgb * pulse, glow_color.a), outline - base_color.a);
    
    // 4. Apply the damage flash (only to the core sprite, leaving the glow untouched)
    if (flash_modifier > 0.0) {
        vec3 flash = mix(final_color.rgb, flash_color.rgb, flash_modifier);
        // We only apply the white flash where the original sprite's alpha exists
        final_color.rgb = mix(final_color.rgb, flash, base_color.a);
    }
    
    COLOR = final_color;
}