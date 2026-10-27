extends Control

signal menu_closed

const INPUT_CONFIG_PREFIX = "inputbind_"
const INPUT_CONFIG_SEPARATOR = ";"
const action_symbol_scene = preload("res://input/ActionSymbol.tscn")
const font = preload("res://assets/fonts/Jacquard_24/FontSmall.tres")
const input_symbol_generator_scene = preload("res://input/InputSymbolGenerator.tscn")

var input_symbol_generator: Control
var is_recording: bool = false
var target_action: String
var current_event: InputEvent

func get_modifiers(action: InputEventWithModifiers) -> PoolStringArray:
	var modifiers = PoolStringArray()
	if action.alt:
		modifiers.append("alt")
	if action.control:
		modifiers.append("control")
	if action.shift:
		modifiers.append("shift")
	return modifiers

func serialize_action(action: InputEvent) -> String:
	if action is InputEventJoypadMotion:
		return "JoyAxis_%s_%s" % [action.axis, ["", "r", "l"][int(action.axis_value)]]
	if action is InputEventJoypadButton:
		return "JoyButton_%s" % action.button_index
	if action is InputEventKey:
		return "Key_%s_%s" % [action.scancode, "_".join(get_modifiers(action))]
	return ""


func deserialize_action(action_string: String) -> InputEvent:
	var action_parts: Array = action_string.lstrip("\n ").rstrip("\n ").split("_")
	var action_identifier = action_parts.pop_front()
	var action: InputEvent = null
	if action_identifier == "Key":
		action = InputEventKey.new()
		action.scancode = int(action_parts.pop_front())
		for modifier in action_parts:
			action.alt = (modifier == "alt") or action.alt
			action.control = (modifier == "control") or action.control
			action.shift = (modifier == "shift") or action.shift
	elif action_identifier == "JoyButton":
		action = InputEventJoypadButton.new()
		action.button_index = int(action_parts.pop_front())
	elif action_identifier == "JoyAxis":
		action = InputEventJoypadMotion.new()
		action.axis = int(action_parts.pop_front())
		action.axis_value = {"l": -1, "r": 1}[action_parts.pop_front()]
	return action

func save_keybinds() -> void:
	var saved = {}
	for action in InputMap.get_actions():
		var serialized = PoolStringArray()
		for event in InputMap.get_action_list(action):
			var value = serialize_action(event)
			if not value.empty():
				serialized.append(value)
		saved[INPUT_CONFIG_PREFIX + action] = \
			INPUT_CONFIG_SEPARATOR.join(serialized)
	Globals.update_config(saved)


func load_keybinds() -> void:
	for action in InputMap.get_actions():
		var config_key = INPUT_CONFIG_PREFIX + action
		if not Globals.config.has(config_key):
			continue
		var serialized = str(Globals.config[config_key])
		var old_events = InputMap.get_action_list(action).duplicate()
		for old_event in old_events:
			InputMap.action_erase_event(action, old_event)
		if serialized.empty():
			continue
		for value in serialized.split(INPUT_CONFIG_SEPARATOR):
			var event = deserialize_action(value)
			if event != null:
				InputMap.action_add_event(action, event)

func _input(event: InputEvent):
	if is_recording:
		if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
			get_tree().set_input_as_handled()
			if not event.is_pressed() or (event is InputEventJoypadMotion and event.axis_value == 0):
				is_recording = false
				$NewKeyDialog.hide()
				InputMap.action_add_event(target_action, current_event)
				var ccount = get_node("InputManagementContainer/" + target_action).get_child(0).get_child_count()
				var hseparator = get_node("InputManagementContainer/" + target_action).get_child(0).get_child(ccount - 3)
				var add_button = get_node("InputManagementContainer/" + target_action).get_child(0).get_child(ccount - 2)
				var back_button = get_node("InputManagementContainer/" + target_action).get_child(0).get_child(ccount - 1)
				var symbols = yield(get_symbol(current_event), "completed")
				var button = action_symbol_scene.instance()
				button.append_bbcode("[center]")
				for texture in symbols:
					button.add_image(texture)
				button.connect("button_up", self, "remove_binding", [target_action, ccount - 4])
				get_node("InputManagementContainer/" + target_action).get_child(0).add_child(button)
				hseparator.raise()
				add_button.raise()
				back_button.raise()
				get_node("InputManagementContainer/" + target_action).get_child(0).update()
				save_keybinds()
			else:
				current_event = event
				var symbols = yield(get_symbol(event), "completed")
				while len(symbols) > $NewKeyDialog/HBoxContainer.get_child_count():
					var texture_rect = TextureRect.new()
					texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
					$NewKeyDialog/HBoxContainer.add_child(texture_rect)
				while len(symbols) < $NewKeyDialog/HBoxContainer.get_child_count():
					$NewKeyDialog/HBoxContainer.get_child(0).free()
				var idx = 0
				for symbol in symbols:
					$NewKeyDialog/HBoxContainer.get_child(idx).texture = symbol
					idx += 1

func get_symbol(event: InputEvent) -> Array:
	var symbols = []
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

func get_action_symbols(action: String) -> Array:
	var symbols = []
	for event in InputMap.get_action_list(action):
		if symbols:
			symbols.append(" or ")
		symbols += yield(get_symbol(event), "completed")
	return symbols

func render_actions():
	for action in InputMap.get_actions():
		var button = UIButton.new()
		button.text = Locale.get_action_translation(action)
		button.connect("button_down", self, "_on_Action_selected", [action])
		$InputManagementContainer/ScrollContainer/Actions.add_child(button)
		var action_container_parent = ScrollContainer.new()
		action_container_parent.name = action
		action_container_parent.rect_min_size = Vector2(200, 500)
		action_container_parent.rect_position = Vector2(1024, 0)
		action_container_parent.scroll_horizontal_enabled = false
		var action_container = VButtonMenu.new()
		action_container.rect_min_size = Vector2(200, 0)
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
		save_keybinds()
	$InputManagementContainer/ScrollContainer/Actions.add_child(HSeparator.new())
	var reset_button = UIButton.new()
	reset_button.text = Locale.get_action_translation("reset") # Yes, I was too lasy to do this correctly
	reset_button.connect("button_up", self, "reset_binds")
	$InputManagementContainer/ScrollContainer/Actions.add_child(reset_button)
	var leave_button = UIButton.new()
	leave_button.text = Locale.get_action_translation("back") # And here, too
	leave_button.connect("button_up", self, "leave_menu")
	$InputManagementContainer/ScrollContainer/Actions.add_child(leave_button)
	$InputManagementContainer/ScrollContainer/Actions.update()

func reset_binds():
	InputMap.load_from_globals()
	save_keybinds()
	$InputManagementContainer/ScrollContainer/Actions.activate()

func remove_binding(action: String, binding_index: int):
	var action_event = InputMap.get_action_list(action)[binding_index]
	InputMap.action_erase_event(action, action_event)
	get_node("InputManagementContainer/" + action).get_child(0).get_child(binding_index).queue_free()
	yield(get_tree(), "idle_frame")
	var index = 0
	for child in get_node("InputManagementContainer/" + action).get_child(0).get_children():
		if child is HSeparator:
			break
		child.disconnect("button_up", self, "remove_binding")
		child.connect("button_up", self, "remove_binding", [action, index])
		index += 1
	save_keybinds()
	get_node("InputManagementContainer/" + action).get_child(0).update()
	get_node("InputManagementContainer/" + action).get_child(0).activate()

func new_action_binding(action):
	target_action = action
	current_event = null
	is_recording = true
	$NewKeyDialog.popup_centered()

func leave_menu():
	emit_signal("menu_closed")
	$Tween.interpolate_property($InputManagementContainer, "rect_position", null, Vector2(1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	hide()

func _on_Action_selected(action: String):
	var action_container = get_node("InputManagementContainer/" + action)
	$Tween.interpolate_property(action_container, "rect_position", null, Vector2(412, 0), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 1)
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
	show()
	$Tween.interpolate_property($InputManagementContainer, "rect_position", null, Vector2(0, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$InputManagementContainer/ScrollContainer/Actions.activate()

func update_locale(_new_locale: String) -> void:
	for child in $InputManagementContainer.get_children():
		if child.name != "ScrollContainer":
			child.queue_free()
	for child in $InputManagementContainer/ScrollContainer/Actions.get_children():
		child.queue_free()
	$NewKeyDialog.window_title = Locale.get_action_translation("add") # Please forgive me
	render_actions()

func _ready():
# warning-ignore:return_value_discarded
	Locale.connect("locale_changed", self, "update_locale")
	input_symbol_generator = input_symbol_generator_scene.instance()
	add_child(input_symbol_generator)
	load_keybinds()
	update_locale("") # This was lazyness, too, as this simplifies things.

func _on_NewKeyDialog_popup_hide():
	is_recording = false
	for child in $NewKeyDialog/HBoxContainer.get_children():
		child.queue_free()
	get_node("InputManagementContainer/" + target_action).get_child(0).activate()
