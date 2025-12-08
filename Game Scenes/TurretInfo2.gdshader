shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float block_size = 16.0;

void fragment() {
    vec2 uv = UV;
    vec2 block = floor(uv * block_size);
    float r = fract(sin(dot(block, vec2(12.9898,78.233))) * 43758.5453);

    // Always sample original label pixel
    vec4 tex_color = texture(TEXTURE, uv);

    // If this block is revealed → draw its original color (including font colors)
    if (r < progress) {
        // Multiply by final vertex color so RichTextLabel formatting is preserved
        COLOR = tex_color * COLOR;
    }
    else {
        // Keep it transparent but do NOT overwrite COLOR's tint info
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
