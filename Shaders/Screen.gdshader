shader_type canvas_item;
render_mode blend_mix, unshaded; // Add unshaded render mode for cleaner color overlay

// --- NEW LINE ADDED TO FIX SCREEN_TEXTURE ERROR ---
uniform sampler2D screen_texture : hint_screen_texture; 

// Color for the glowing highlights (the holographic effect color)
uniform vec4 highlight_color = vec4(0.0, 0.8, 1.0, 0.6); // Slightly more transparent
// Speed and direction of the noise/scanline effect
uniform float scan_speed = 1.0; // Increased speed for more movement
// Intensity of the flickering noise effect
uniform float noise_intensity = 0.05;
// Transparency of the underlying UI (0.0=Invisible, 1.0=Fully Opaque)
uniform float base_transparency = 0.9; // Make underlying UI slightly more opaque

// --- Main Fragment Function ---
void fragment() {
    // 1. Get the underlying color from the screen (the UI elements beneath this ColorRect)
    vec4 existing_color = texture(screen_texture, SCREEN_UV); 

    // 2. Setup UV Coordinates (using SCREEN_UV for screen-space effects)
    vec2 uv = SCREEN_UV;
    
    // --- Grid Calculation REMOVED ---
    
    // 3. Add Dynamic Noise/Scanline Effect
    
    // Scanline Effect (moves vertically, creating a subtle horizontal line wipe)
    float scan = sin(uv.y * 30.0 + TIME * scan_speed);
    // Amplify the effect in the 0-1 range
    scan = (scan + 1.0) * 0.5; 

    // Flickering Noise/Static Effect
    // TEXTURE is used as a generic noise source (ensure this ColorRect has a default texture or uses TEXTURE_PIXEL_SIZE)
    // We use uv * 100.0 to make the noise pattern fine and tight.
    float noise = texture(TEXTURE, uv * 100.0).r;
    noise = clamp(noise * noise_intensity, 0.0, 1.0); // Control the intensity

    // 4. Combine and Mix Colors
    // The final factor determines where the holographic color is applied
    float final_factor = scan * noise * 2.0; // Combine scan and noise for flickering lines
    
    // Apply the holographic color as a subtle, flickering layer over the existing color
    // Use the final_factor to control the blending.
    vec4 highlight_overlay = mix(existing_color, highlight_color, final_factor);

    // Set the final color and transparency
    COLOR.rgb = highlight_overlay.rgb;
    COLOR.a = existing_color.a * base_transparency;
}