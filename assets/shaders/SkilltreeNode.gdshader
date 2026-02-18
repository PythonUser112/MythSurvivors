shader_type canvas_item;

uniform vec4 color;
uniform float color_shades = 16.0;
uniform float pix = 16;
uniform vec2 size = vec2(64, 64);

void fragment() {
	vec2 pos = floor(UV * size + vec2(0.5, 0.5)) / size;
	float x_2 = (pos.x - 0.5) * (pos.x - 0.5);
	float y_2 = (pos.y - 0.5) * (pos.y - 0.5);
	float fac = 1.0 - min((3.5 * (x_2 + y_2)), 1.0);
	float fac_pix = round(pix * fac) / pix;
	COLOR = round(color_shades * fac_pix * color) / color_shades;
}
