shader_type canvas_item;

uniform float saturation : hint_range(0.0, 1.0) = 0.0;
uniform int active_shards : hint_range(0, 4) = 0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculate standard greyscale
    float lum = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 greyscale = vec3(lum);
    
    // Determine which of the 4 quadrants this pixel is in
    // 0 = Top-Left, 1 = Top-Right, 2 = Bottom-Left, 3 = Bottom-Right
    int quad_index = 0;
    if (UV.y < 0.5) {
        if (UV.x >= 0.5) quad_index = 1;
    } else {
        if (UV.x < 0.5) quad_index = 2;
        else quad_index = 3;
    }
    
    // If the entire turret is unlocked, or this specific quadrant is unlocked via a shard, keep the color.
    float current_sat = saturation;
    if (saturation < 1.0 && quad_index < active_shards) {
        current_sat = 1.0;
    }
    
    COLOR.rgb = mix(greyscale, tex_color.rgb, current_sat);
    COLOR.a = tex_color.a;
}