tool

extends ColorRect
class_name Stars

export (int) var star_count = 250
export (float) var star_blink_speed = 5.0

var star_shader = preload("res://assets/shaders/StarBlinkShader.tres")

func _ready():
	redraw()

func redraw():
	for _i in range(star_count):
		var star = ColorRect.new()
		star.rect_size = Vector2(1, 1)
		var x = randi() % int(rect_size.x)
		var y = randi() % int(rect_size.y)
		if x == 0 and y == 0:
			x = 1
		var size = float(randi() % 20) / 10
		star.rect_size = Vector2(size, size)
		star.rect_position = Vector2(x, y)
		star.material = ShaderMaterial.new()
		star.material.shader = star_shader
		star.material.set_shader_param("speed", (randi() % 100 + 1) / 50.0 * star_blink_speed)
		star.material.set_shader_param("bg_color", color)
		star.material.set_shader_param("glow", (randi() % 100) / 200.0)
		star.material.set_shader_param("intensity", (randi() % 100) / 200.0 + 0.5)
		add_child(star)

