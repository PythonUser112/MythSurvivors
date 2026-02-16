shader_type canvas_item;

uniform vec4 color;
uniform float colors = 8;

void fragment() {
	vec2 pos = round(UV * TEXTURE_PIXEL_SIZE) / TEXTURE_PIXEL_SIZE;
	float dist = 1.0 - pow(2.0 * abs(0.5 - UV.x), 2);
	dist = ceil(dist * colors) / colors;
	COLOR = color * dist;
}