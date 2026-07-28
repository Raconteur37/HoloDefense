shader_type canvas_item;

// The 1 to 11 scale
uniform float intensity : hint_range(1.0, 11.0) = 1.0;

// Base holographic cyan/blue
uniform vec4 holo_color : source_color = vec4(0.0, 0.6, 1.0, 1.0);
// High-energy color that takes over at intensity 11
uniform vec4 overdrive_color : source_color = vec4(1.0, 0.0, 0.3, 1.0); 

// Smooth pseudo-random hash for data generation
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // Normalize intensity to 0.0 - 1.0
    float t = (intensity - 1.0) / 10.0;
    
    vec2 uv = UV - 0.5;
    float r = length(uv);
    float theta = atan(uv.y, uv.x);
    
    // --- 1. Core Masks ---
    // Crisp event horizon (the absolute black hole in the center)
    float core_mask = smoothstep(0.06, 0.12, r);
    // Smooth fade out at the edges so it blends into your UI panel
    float edge_fade = smoothstep(0.48, 0.2, r);
    
    // --- 2. Gravitational Math (Spaghettification) ---
    // Inverse radius curves space: things stretch dramatically as they fall in
    float inv_r = 0.25 / (r + 0.02);
    
    // Speed scales drastically with intensity
    float pull_speed = TIME * (2.0 + t * 8.0);
    float spin_speed = TIME * (0.5 + t * 3.0);
    
    // Twist the space to create the whirlpool effect
    float twist = inv_r * (1.0 + t * 3.0);
    float warped_theta = theta + twist - spin_speed;
    
    // --- 3. Clean Procedural Data Arcs ---
    // Create concentric rings falling inward
    float ring_domain = inv_r * 8.0 - pull_speed; 
    float ring_id = floor(ring_domain);
    float ring_local = fract(ring_domain);
    
    // Make the rings crisp and thin
    float ring_line = smoothstep(0.1, 0.3, ring_local) * smoothstep(0.9, 0.7, ring_local);
    
    // Generate a random seed for each ring
    float r_hash = hash(vec2(ring_id, 1.0));
    
    // Alternate spin directions per ring for a high-tech machinery feel
    float dir = r_hash > 0.5 ? 1.0 : -1.0;
    
    // Segment the rings into dashed data chunks
    // (Using floor ensures an integer number of segments so there is no visual seam!)
    float segments = floor(8.0 + r_hash * 20.0); 
    float seg_theta = warped_theta * dir * (segments / 6.28318);
    float seg_id = floor(seg_theta);
    float seg_local = fract(seg_theta);
    
    // Crisp edges for the individual data arcs
    float arc = smoothstep(0.05, 0.15, seg_local) * smoothstep(0.95, 0.85, seg_local);
    
    // Randomly drop some arcs to make it look like streaming digital data
    float drop_hash = hash(vec2(ring_id, seg_id));
    float data_density = 0.4 + (t * 0.4); // Populates more data as intensity rises
    float is_visible = step(1.0 - data_density, drop_hash);
    
    float data_rings = ring_line * arc * is_visible;
    
    // --- 4. Accretion Disc (Event Horizon Glow) ---
    // A bright, intense energy ring bordering the singularity
    float horizon = smoothstep(0.18, 0.11, r) * smoothstep(0.05, 0.11, r);
    float pulse = 1.0 + 0.4 * sin(TIME * (8.0 + t * 12.0));
    horizon *= pulse;
    
    // --- 5. Color and Composition ---
    vec4 color_mix = mix(holo_color, overdrive_color, pow(t, 1.5));
    
    // Add extreme heat (white/yellow) to the horizon at high intensities
    vec3 heat_color = mix(color_mix.rgb, vec3(1.0, 0.9, 0.8), t * 0.7);
    vec3 final_rgb = mix(color_mix.rgb, heat_color, horizon);
    
    // Ambient suction glow
    float ambient_glow = (0.02 / (r + 0.01)) * t;
    
    // Combine layers
    float final_alpha = (data_rings + (horizon * 2.5) + ambient_glow) * core_mask * edge_fade;
    
    // Global brightness boost for maximum chaos at intensity 11
    final_alpha *= (1.0 + t * 1.5);
    
    COLOR = vec4(final_rgb, clamp(final_alpha, 0.0, 1.0) * color_mix.a);
}