shader_type canvas_item;

// The 1 to 11 scale
uniform float intensity : hint_range(1.0, 11.0) = 1.0;

// Base holographic cyan/blue
uniform vec4 holo_color : source_color = vec4(0.0, 0.5, 1.0, 1.0);
// High-energy color that takes over at intensity 11
uniform vec4 overdrive_color : source_color = vec4(1.0, 0.0, 0.4, 1.0); 

// Helper function to generate random values for the data squares
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // Normalize the 1-11 scale to a 0.0-1.0 range for smoother math
    float t = (intensity - 1.0) / 10.0;
    
    // Center the UV coordinates so the singularity is perfectly in the middle
    vec2 centered_uv = UV - vec2(0.5);
    
    // Convert to polar coordinates (radius and angle) for the suction effect
    float radius = length(centered_uv);
    float angle = atan(centered_uv.y, centered_uv.x);
    
    // --- 1. Math for the Suction Warp ---
    // Speed increases drastically as intensity goes up
    float pull_speed = TIME * (1.0 + t * 8.0);
    
    // Invert the radius so coordinates stretch out toward infinity at the center
    float inverse_radius = 0.5 / (radius + 0.01);
    
    // Pull inward by adding speed to the inverse radius
    float radius_warp = inverse_radius + pull_speed;
    
    // Add a twist that gets stronger at high intensity
    float twist_strength = t * 2.5;
    float angle_warp = angle + (inverse_radius * twist_strength);
    
    // --- 2. Procedural Data Squares ---
    // Create a grid out of the warped polar coordinates
    // We add more rings and slices as intensity increases
    vec2 grid_uv = vec2(radius_warp * 6.0, angle_warp * (8.0 + t * 12.0)); 
    
    vec2 cell = floor(grid_uv);
    vec2 local_uv = fract(grid_uv);
    
    // Random chance for a square to spawn in a cell
    float random_val = hash(cell);
    
    // Increase the density of squares at higher intensities
    float density = 0.6 + (t * 0.3);
    float square_mask = step(density, random_val); 
    
    // Carve out the square shape from the local cell (adds padding so they don't touch)
    float box = step(0.15, local_uv.x) * step(local_uv.x, 0.85) *
                step(0.15, local_uv.y) * step(local_uv.y, 0.85);
                
    float final_squares = square_mask * box;
    
    // --- 3. The Core and Edge Fading ---
    // Hollow out the absolute center so it looks like a black hole
    float core_mask = smoothstep(0.0, 0.1, radius);
    
    // Fade out the edges of the TextureRect so it blends seamlessly into your UI
    float edge_fade = smoothstep(0.5, 0.2, radius);
    
    // --- 4. Color and Glow Blending ---
    // Exponentially shift to the overdrive color so it only really hits at level 9, 10, and 11
    vec4 current_color = mix(holo_color, overdrive_color, pow(t, 2.5));
    
    // Add a pulsing energy glow around the singularity
    float glow = (0.05 / (radius + 0.01)) * (1.0 + sin(TIME * 15.0 * t) * 0.5 * t);
    
    // Combine the squares and the glow, apply the masks
    float final_alpha = (final_squares + glow) * core_mask * edge_fade;
    
    // Boost overall brightness at high intensity
    final_alpha *= (1.0 + t * 2.0);
    
    COLOR = vec4(current_color.rgb, clamp(final_alpha, 0.0, 1.0) * current_color.a);
}