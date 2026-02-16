extends ColorRect

export (bool) var active

func _ready():
	material = ShaderMaterial.new()
	material.shader = preload("res://assets/shaders/SkilltreeConnection.gdshader")
	update()

func update():
	.update()
	if active:
		material.set_shader_param("color", color)
	else:
		material.set_shader_param("color", Color(0.5, 0.5, 0.5, 1) * color)
