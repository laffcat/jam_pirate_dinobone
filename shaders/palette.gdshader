shader_type canvas_item;

uniform vec4 colors[11]: source_color;

int return_index(float raw) { return int(round(raw * 10.0)); }

void fragment() {
	float alpha = COLOR.a;
	COLOR = colors[return_index(COLOR.r)]; // Red 25 == COLOR.r .1 == colors[1]
	COLOR.a *= alpha;
}
