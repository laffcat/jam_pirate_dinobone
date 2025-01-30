shader_type canvas_item;

uniform float threshold : hint_range(0.0, 1.0);
uniform vec3 color2 : source_color;

float gtz(float input) { return max(0, sign(input)); }
// returns 1.0 if input > 0, else 0.0

void fragment() {
	COLOR.rgb = mix( COLOR.rgb, color2, gtz(UV.x - threshold) );
}


