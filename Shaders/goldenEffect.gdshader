shader_type canvas_item;

uniform vec4 gold_color : source_color = vec4(1.0, 0.85, 0.0, 1.0);
uniform float intensity : hint_range(0.0, 2.0) = 1.2;
uniform float shine_speed : hint_range(0.0, 5.0) = 0.2;
uniform float shine_width : hint_range(0.01, 1.0) = 0.15;
uniform float mix_amount : hint_range(0.0, 1.0) = 1.0; // 0 is normal, 1 is fully golden

void fragment() {
    // Get the original texture pixel
    vec4 original_color = texture(TEXTURE, UV);
    
    // Ignore transparent pixels entirely
    if (original_color.a > 0.0) {
        
        // Convert the original pixel to grayscale (preserves shading/texture)
        float gray = dot(original_color.rgb, vec3(0.299, 0.587, 0.114));
        
        // Multiply the grayscale by our gold color and boost the brightness
        vec3 golden_tint = gray * gold_color.rgb * intensity;
        
        // Create a moving diagonal line for the "shine" effect
        float shine_pos = fract(TIME * shine_speed);
        
        // UV.x + UV.y creates a diagonal angle. We scale it slightly.
        float uv_diagonal = (UV.x + UV.y) * 0.5; 
        
        // Calculate how close this pixel is to the moving shine line
        float shine = smoothstep(shine_width, 0.0, abs(uv_diagonal - shine_pos));
        
        // Add the shine highlight (bright white/yellow)
        vec3 final_color = golden_tint + vec3(shine * 0.7);
        
        // Blend between the original sprite color and the gold buff color
        vec3 mixed_color = mix(original_color.rgb, final_color, mix_amount);
        
        // Output the new color, keeping the original alpha intact
        COLOR = vec4(mixed_color, original_color.a);
    } else {
        COLOR = original_color;
    }
}