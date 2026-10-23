extends Control

signal menu_closed

var action_symbol_scene = preload("res://input/ActionSymbol.tscn")
var font = preload("res://assets/fonts/Jacquard_24/FontSmall.tres")
var input_symbol_generator_scene = preload("res://input/InputSymbolGenerator.tscn")
var input_symbol_generator

func get_action_symbols(action: String) -> Array:
	var symbols = []
	for event in InputMap.get_action_list(action):
		if symbols:
			symbols.append(" or ")
		if event is InputEventKey:
			if event.control:
				symbols.append(yield(input_symbol_generator.get_key_symbol(input_symbol_generator.KEYBOARD, KEY_CONTROL), "completed"))
			if event.shift:
				symbols.append(yield(input_symbol_generator.get_key_symbol(input_symbol_generator.KEYBOARD, KEY_SHIFT), "completed"))
			if event.alt:
				symbols.append(yield(input_symbol_generator.get_key_symbol(input_symbol_generator.KEYBOARD, KEY_ALT), "completed"))
			symbols.append(yield(input_symbol_generator.get_key_symbol(input_symbol_generator.KEYBOARD, event.scancode), "completed"))
		elif event is InputEventJoypadButton:
			symbols.append(yield(input_symbol_generator.get_key_symbol(input_symbol_generator.JOYBUTTON, event.button_index), "completed"))
		elif event is InputEventJoypadMotion:
			var axis_pos = ["L", "R"][int(event.axis / 2)]
			symbols.append(axis_pos)
			var stick_name = ["0", "1"][event.axis % 2]
			if event.axis_value > 0:
				stick_name += "+"
			else:
				stick_name += "-"
			symbols.append(yield(input_symbol_generator.get_key_symbol(input_symbol_generator.JOYSTICK, stick_name), "completed"))
	return symbols

func render_actions():
	for action in InputMap.get_actions():
		var button = UIButton.new()
		button.text = action
		button.connect("button_down", self, "_on_Action_selected", [action])
		$InputManagementContainer/ScrollContainer/Actions.add_child(button)
		var action_container_parent = ScrollContainer.new()
		action_container_parent.name = action
		action_container_parent.rect_min_size = Vector2(100, 0)
		action_container_parent.rect_position = Vector2(1024, 0)
		action_container_parent.scroll_horizontal_enabled = false
		var action_container = VButtonMenu.new()
		action_container.rect_min_size = Vector2(100, 0)
		var current_button = action_symbol_scene.instance()
		current_button.connect("button_up", self, "remove_binding", [action, 0])
		current_button.append_bbcode("[center]")
		var index = 0
		var symbols = yield(get_action_symbols(action), "completed")
		for symbol in symbols:
			if symbol is String:
				if symbol == " or ":
					action_container.add_child(current_button)
					current_button = action_symbol_scene.instance()
					current_button.append_bbcode("[center]")
					index += 1
					current_button.connect("button_up", self, "remove_binding", [action, index])
				else:
					current_button.append_bbcode(symbol)
			elif symbol is Texture:
				current_button.add_image(symbol)
		action_container.add_child(current_button)
		action_container.add_child(HSeparator.new())
		var new_button = action_symbol_scene.instance()
		new_button.bbcode_text = "[center]Add binding[/center]"
		new_button.connect("button_up", self, "new_action_binding", [action])
		action_container.add_child(new_button)
		var back_button = action_symbol_scene.instance()
		back_button.bbcode_text = "[center]Back[/center]"
		back_button.connect("button_up", self, "to_action_menu", [action])
		action_container.add_child(back_button)
		action_container_parent.add_child(action_container)
		$InputManagementContainer.add_child(action_container_parent)
	$InputManagementContainer/ScrollContainer/Actions.add_child(HSeparator.new())
	var leave_button = UIButton.new()
	leave_button.text = "Back"
	leave_button.connect("button_up", self, "leave_menu")
	$InputManagementContainer/ScrollContainer/Actions.add_child(leave_button)
	$InputManagementContainer/ScrollContainer/Actions.update()

func leave_menu():
	emit_signal("menu_closed")
	$Tween.interpolate_property($InputManagementContainer, "rect_position", null, Vector2(1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Action_selected(action: String):
	var action_container = get_node("InputManagementContainer/" + action)
	$Tween.interpolate_property(action_container, "rect_position", null, Vector2(462, 0), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 1)
	$Tween.interpolate_property($InputManagementContainer/ScrollContainer, "rect_position", null, Vector2(-400, 0), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	action_container.get_child(0).activate()

func to_action_menu(last_action: String):
	var action_container = get_node("InputManagementContainer/" + last_action)
	$Tween.interpolate_property(action_container, "rect_position", null, Vector2(1024, 0), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($InputManagementContainer/ScrollContainer, "rect_position", null, Vector2(362, 0), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$InputManagementContainer/ScrollContainer/Actions.activate()

func activate():
	$Tween.interpolate_property($InputManagementContainer, "rect_position", null, Vector2(0, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$InputManagementContainer/ScrollContainer/Actions.activate()

func _ready():
	input_symbol_generator = input_symbol_generator_scene.instance()
	add_child(input_symbol_generator)
	render_actions()
