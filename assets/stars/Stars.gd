tool

extends ColorRect
class_name Stars

export (int) var star_count = 250
export (float) var star_blink_speed = 5.0

var star_shader = preload("res://assets/shaders/StarBlinkShader.tres")

func _ready():
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
		star.material.set_shader_param("bg_color", color)
		star.material.set_shader_param("speed", star_blink_speed * float(randi() % 100) / 50)
		star.material.set_shader_param("position", star.rect_position / rect_size)
		add_child(star)

