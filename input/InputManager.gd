extends Control

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
		var container = HBoxContainer.new()
		$InputManagementContainer/ScrollContainer/Actions.add_child(container)
		var label = RichTextLabel.new()
		label.rect_min_size = Vector2(100, 0)
		label.fit_content_height = true
		label.text = action
		container.add_child(label)
		var symbol_list = VButtonMenu.new()
		symbol_list.deactivate_on_press = false
		container.add_child(symbol_list)
		var symbols = yield(get_action_symbols(action), "completed")
		var action_symbol = action_symbol_scene.instance()
		for symbol in symbols:
			if symbol is ImageTexture:
				action_symbol.add_image(symbol)
				action_symbol.rect_min_size.x += symbol.get_width()
			elif symbol == " or ":
				symbol_list.add_child(action_symbol)
				action_symbol = action_symbol_scene.instance()
			else:
				action_symbol.append_bbcode(symbol)
				action_symbol.rect_min_size.x += font.get_wordwrap_string_size(symbol, INF).x

func _ready():
	input_symbol_generator = input_symbol_generator_scene.instance()
	add_child(input_symbol_generator)
	render_actions()
