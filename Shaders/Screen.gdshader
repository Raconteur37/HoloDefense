shader_type canvas_item;

// Number of orbs
uniform int orb_count : hint_range(1, 100) = 12;

// Orb radius in normalized UV space (0–1)
uniform float orb_radius : hint_range(0.001, 0.2) = 0.05;

// Movement speed
uniform float speed : hint_range(0.0, 5.0) = 1.0;

// Color of holographic glow
uniform vec4 orb_color : source_color = vec4(0.3, 0.9, 1.0, 0.45);


// Simple pseudo-random generator
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Soft-edged circle (0 at edge, 1 at center)
float soft_circle(vec2 uv, vec2 center, float radius) {
    float d = distance(uv, center);
    return smoothstep(radius, radius * 0.7, d); 
}

void fragment() {
    vec2 uv = UV;   // 0–1 UVs across the UI element

    float glow = 0.0;

    for (int i = 0; i < orb_count; i++) {

        float id = float(i);

        // Base pseudo-random position
        vec2 seed = vec2(hash(vec2(id, id * 13.1)), 
                         hash(vec2(id * 7.3, id)));

        vec2 pos = seed;

        // Floating animation
        float t = TIME * speed;
        pos.x += sin(t + id * 3.1) * 0.04;
        pos.y += cos(t * 0.7 + id * 4.7) * 0.04;

        // Add this orb's glow
        glow += soft_circle(uv, pos, orb_radius);
    }

    // Clamp glow to prevent blowing out
    glow = clamp(glow, 0.0, 1.0);

    COLOR = orb_color * glow;
}
