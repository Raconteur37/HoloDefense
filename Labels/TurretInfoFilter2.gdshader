shader_type canvas_item;

uniform float dim_amount : hint_range(0.0, 1.0) = 0.25; // how much to dim (0 = none, 1 = black)

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    // Multiply the RGB by (1.0 - dim amount)
    col.rgb *= (1.0 - dim_amount);
    COLOR = col;
}
