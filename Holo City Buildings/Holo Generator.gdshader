shader_type canvas_item;

// The texture we use to make the electricity move/distort
uniform sampler2D noise_texture : repeat_enable;

// Settings you can change in the Inspector
uniform vec4 electric_color : source_color = vec4(0.0, 0.8, 1.0, 1.0); // Bright Blue
uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform float distortion_strength : hint_range(0.0, 1.0) = 0.2;
uniform float sparkle_strength : hint_range(0.0, 2.0) = 0.5;

void fragment() {
	// Get the original texture of the progress bar
	vec4 color = texture(TEXTURE, UV);
	
	// Create moving coordinates for the noise
	// This makes the noise "scroll" horizontally over time
// Check that your code looks like this:
	vec2 moving_uv = UV + vec2(TIME * speed * 0.5, TIME * speed * 0.2);
	
	// Sample the moving noise texture
	// Using .r because noise is usually grayscale (red channel is enough)
	float noise_value = texture(noise_texture, moving_uv).r;
	
	// --- ELECTRIC DISTORTION ---
	// We use the noise value to slightly shift the green channel of the main color
	// This creates a shimmering, unstable effect
	float distortion = (noise_value - 0.5) * distortion_strength;
	color.g += distortion;
	
	// --- ELECTRIC SPARKLE ---
	// We make certain spots very bright based on the noise peaks
	float sparkle = max(0.0, (noise_value - 0.7) * sparkle_strength);
	color.rgb += sparkle;
	
	// --- COLORING & PROGRESS ---
	// Multiple the result by our electric color and the original texture's alpha
	// This ensures it looks like the chosen color and only appears where the bar is "filled"
	COLOR = color * electric_color;
	COLOR.a *= texture(TEXTURE, UV).a;
}