extends Control

export (String) var character_name
export (int) var move_speed = 300

const skilltree_node_scene = preload("res://assets/skilltree/SkilltreeNode.tscn")
const skilltree_connection_scene = preload("res://assets/skilltree/SkilltreeConnection.tscn")

var dragging = false
var dragging_start
var tree: Skills.Skilltree

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

func _gui_input(event):
	if event is InputEventMouseMotion and dragging:
		$Camera2D.position -= event.global_position - dragging_start
		dragging_start = event.global_position
	if event is InputEventMouseButton:
		if $InfoLayer/SkillInformation.rect_position.x < 1024:
			$Tween.interpolate_property($InfoLayer/SkillInformation, "rect_position", null, Vector2(1024, 0), 1, Tween.TRANS_CUBIC)
			$Tween.start()
			yield($Tween, "tween_all_completed")
		if event.pressed:
			dragging = true
			dragging_start = event.global_position
		else:
			dragging = false

func skill_pressed(skill_name: String):
	if $InfoLayer/SkillInformation.rect_position.x < 1024:
		$Tween.interpolate_property($InfoLayer/SkillInformation, "rect_position", null, Vector2(1024, 0), 1, Tween.TRANS_CUBIC)
		$Tween.start()
		yield($Tween, "tween_all_completed")
	var text = "[jump_pulse]\n"
	var attributes = tree.get_skill_attributes(skill_name.to_lower().replace(" ", "_"))
	for attribute in attributes:
		text += Locale.get_stat(attribute)
		text += ": "
		if attributes[attribute] > 0:
			text += "+"
		text += str(attributes[attribute])
		text += "%\n"
	text += "[/jump_pulse]"
	if not tree.is_skill_active(skill_name.to_lower()):
		$InfoLayer/SkillInformation/PurchaseButton.disabled = $InfoLayer/XPBar.value < tree.get_skill_cost(skill_name.to_lower().replace(" ", "_")) or not tree.unlockable(skill_name.to_lower().replace(" ", "_"))
		$InfoLayer/SkillInformation/Costs.bbcode_text = "\n[center][jump_pulse]%s XP[/jump_pulse][/center]" % (tree.get_skill_cost(skill_name.to_lower().replace(" ", "_")))
		$InfoLayer/SkillInformation/Costs.show()
		$InfoLayer/SkillInformation/PurchaseButton.show()
	else:
		$InfoLayer/SkillInformation/Costs.hide()
		$InfoLayer/SkillInformation/PurchaseButton.hide()
	$InfoLayer/SkillInformation/Attributes.bbcode_text = text
	$InfoLayer/SkillInformation/SkillName.bbcode_text = "\n[center][jump_pulse]" + skill_name + "[/jump_pulse][/center]"
	$Tween.interpolate_property($InfoLayer/SkillInformation, "rect_position", null, Vector2(784, 0), 1, Tween.TRANS_CUBIC)
	$Tween.start()

func _ready():
	var i = 0
	var character = Characters.get_character(character_name)
	tree = character.skilltree
	$InfoLayer/CharacterLabel.bbcode_text = character.to_bbcode()
	$InfoLayer/XPBar.value = character.xp
	$InfoLayer/XPBar/RichTextLabel.bbcode_text = "\n[center][jump_pulse]%s[/jump_pulse][/center]" % (character.xp)
	var skills_positions = {}
	for group in tree.skills_ordered:
		var start_y = float(1200 - len(group) * 192) / 2
		var j = 0
		for skill in group:
			var node = skilltree_node_scene.instance()
			skills_positions[skill] = Vector2(192 * i, 192 * j + start_y)
			node.rect_position = Vector2(192 * i, 192 * j + start_y)
			node.rect_position -= node.shift / 2
			node.skill_name = skill
			node.active = tree.is_skill_active(skill)
			node.bg_color = tree.get_skill_color(skill)
			node.connect("pressed", self, "skill_pressed")
			$Skills.add_child(node)
			j = j + 1
			var deps = tree.get_skill_deps(skill)
			for dep in deps:
				if not dep:
					continue
				var connection = skilltree_connection_scene.instance()
				connection.rect_position = skills_positions[dep] + Vector2(64, 64)
				var a = skills_positions[skill].x - connection.rect_position.x + 64
				var g = skills_positions[skill].y - connection.rect_position.y + 64
				var angle = atan(float(g) / float(a)) - PI / 2.0
				connection.set_rotation(angle)
				connection.rect_size.y = sqrt(a * a + g * g)
				connection.name = skill + dep
				connection.color = tree.get_skill_color(dep)
				connection.active = tree.is_skill_active(dep)
				$Connections.add_child(connection)
		i = i + 1

func _process(delta):
	if Input.is_action_pressed("zoom_in") and $Camera2D.zoom.x > 0.5:
		$Camera2D.zoom -= Vector2(delta, delta)
	if Input.is_action_pressed("zoom_out") and $Camera2D.zoom.x < 2:
		$Camera2D.zoom += Vector2(delta, delta)
	if Input.is_action_pressed("left"):
		$Camera2D.position.x -= delta * move_speed * $Camera2D.zoom.x
	if Input.is_action_pressed("right"):
		$Camera2D.position.x += delta * move_speed * $Camera2D.zoom.x
	if Input.is_action_pressed("up"):
		$Camera2D.position.y -= delta * move_speed * $Camera2D.zoom.x
	if Input.is_action_pressed("down"):
		$Camera2D.position.y += delta * move_speed * $Camera2D.zoom.x
