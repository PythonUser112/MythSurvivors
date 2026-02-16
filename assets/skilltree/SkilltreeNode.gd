extends Control

export (String) var skill_name = "Skill"
export (bool) var active = false
export (Color) var bg_color = Color(0, 0, 1)
export (Vector2) var shift = Vector2(20, 20)

signal pressed

func is_colliding(position: Vector2) -> bool:
	return ($GlowingCircle.rect_size + shift - 2 * position).length() <= $GlowingCircle.rect_size.x

func _ready():
	$GlowingCircle.material = ShaderMaterial.new()
	$GlowingCircle.material.shader = preload("res://assets/shaders/SkilltreeNode.gdshader")
	update()
	$GlowingCircle.rect_position = shift / 2.0
	$RichTextLabel.rect_position = shift / 2.0 + Vector2(0, 80)

func capitalize(string: String) -> String:
	var parts = string.replace("_", " ").split(" ")
	var out = ""
	var i = 0
	for part in parts:
		i = i + 1
		out += part[0].to_upper() + part.right(1)
		if i != len(parts):
			out += " "
	return out

func update():
	rect_size = $GlowingCircle.rect_size + 2 * shift
	.update()
	if active:
		$RichTextLabel.set("custom_colors/color", Color(1, 1, 1))
		$GlowingCircle.material.set_shader_param("color", bg_color * Color(0.9, 0.9, 0.9))
	else:
		$RichTextLabel.set("custom_colors/color", Color(0.5, 0.5, 0.5))
		$GlowingCircle.material.set_shader_param("color", bg_color * Color(0.5, 0.5, 0.5))
	$RichTextLabel.bbcode_text = "\n[center][jump_pulse]%s[/jump_pulse][/center]"%(capitalize(skill_name))

func _gui_input(event):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.button_index == BUTTON_LEFT and event.pressed and is_colliding(event.position):
			emit_signal("pressed", capitalize(skill_name))
	if event is InputEventMouseMotion:
		event = event as InputEventMouseMotion
		if is_colliding(event.position):
			$GlowingCircle.material.set_shader_param("color", bg_color)
		else:
			if active:
				$GlowingCircle.material.set_shader_param("color", bg_color * Color(0.9, 0.9, 0.9))
			else:
				$GlowingCircle.material.set_shader_param("color", bg_color * Color(0.5, 0.5, 0.5))
