shader_type canvas_item;

uniform bool disabled;
uniform float colors = 8;
uniform vec2 pixels = vec2(200.0, 200.0);

void fragment() {
	vec2 pos = round(pixels * UV) / pixels;
	COLOR = texture(TEXTURE, pos);
	if(disabled) {
		float x = 2.0 * UV.x - 1.0;
		float y = 2.0 * UV.y - 1.0;
		float dist = 1.1 - sqrt(x * x + y * y);
		COLOR.r = 0.2 * dist;
		COLOR.b = 0.2 * dist;
		COLOR.g = 0.2 * dist;
	}
	else {
		COLOR = round(colors * COLOR) / colors;
	}
}