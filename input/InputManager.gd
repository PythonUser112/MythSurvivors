extends Control

export (String) var current_profile = "default"
export (String) var profile_path = "user://profile_%s.txt"
export (String) var profile_list = "user://profiles.txt"

enum ActionStatus {
	PRESSED,
	RELEASED
}

var new_events = []
var events = []

var profiles = {}

func _ready():
	load_profiles()

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.pressed:
			new_events.append([InputSymbolGenerator.KEYBOARD, ActionStatus.PRESSED, event])
		else:
			new_events.append([InputSymbolGenerator.KEYBOARD, ActionStatus.RELEASED, event])
	elif event is InputEventJoypadButton:
		if event.pressed:
			new_events.append([InputSymbolGenerator.JOYBUTTON, ActionStatus.PRESSED, event])
		else:
			new_events.append([InputSymbolGenerator.JOYBUTTON, ActionStatus.RELEASED, event])
	elif event is InputEventJoypadMotion:
		new_events.append([InputSymbolGenerator.JOYSTICK, null, event])
	else:
		return

func load_profiles():
	var f = File.new()
	if f.file_exists("res://profiles.txt"):
		f.open("res://profiles.txt", File.READ)
		var profile_names = f.get_as_text().split("\n")
		f.close()
		for profile in profile_names:
			if profile:
				print_debug("Loading profile '%s'" % profile)
				load_profile(profile)
		current_profile = profile_names[0]
	else:
		print_debug("Fallback to default profile!")
		load_profile("default")
		save_profile("default")

func get_action_symbols(action: String, profile: String = "default") -> String:
	var symbols = []
	for event in profiles[profile][action]:
		print(event)
		if symbols:
			symbols.append(" or ")
		if event is InputEventKey:
			if event.control:
				symbols.append(yield(InputSymbolGenerator.get_key_symbol(InputSymbolGenerator.KEYBOARD, KEY_CONTROL), "completed"))
			if event.shift:
				symbols.append(yield(InputSymbolGenerator.get_key_symbol(InputSymbolGenerator.KEYBOARD, KEY_SHIFT), "completed"))
			if event.alt:
				symbols.append(yield(InputSymbolGenerator.get_key_symbol(InputSymbolGenerator.KEYBOARD, KEY_ALT), "completed"))
			symbols.append(yield(InputSymbolGenerator.get_key_symbol(InputSymbolGenerator.KEYBOARD, event.scancode), "completed"))
	return symbols

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
		return "JoyAxis_%s_%s" % [action.axis, ["r", "l"][int(action.axis_value)]]
	if action is InputEventJoypadButton:
		return "JoyButton_%s" % action.button_index
	if action is InputEventKey:
		return "Key_%s_%s" % [action.scancode, "_".join(get_modifiers(action))]
	return ""

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func action_in_list(action: String, status, list: Array) -> bool:
	return false

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

func load_profile(profile: String, profile_name: String = ""):
	if profile_name == "":
		profile_name = profile
	var f = File.new()
	if not f.file_exists(profile_path % profile):
		if profile != "default":
			push_error("Profile '%s' doesn't exist, loading default profile!" % profile)
			load_profile("default", profile)
			return
		else:
			profiles[profile_name] = {}
			for action in InputMap.get_actions():
				var action_list = InputMap.get_action_list(action)
				profiles[profile_name][action] = action_list
			return
	profiles[profile_name] = {}
	f.open(profile_path % profile, File.READ)
	var content = f.get_as_text().split("\n")
	f.close()
	var current_action = ""
	for line in content:
		if line:
			if line.begins_with("- "):
				line = line.right(2)
				profiles[profile_name][current_action].append(deserialize_action(line))
			else:
				current_action = line
				profiles[profile_name][current_action] = []

func save_profile(profile_name: String):
	var whole_string = ""
	for action_name in profiles[profile_name]:
		var action_list: Array = profiles[profile_name][action_name]
		whole_string += action_name + "\n"
		for action in action_list:
			whole_string += "- " + serialize_action(action) + "\n"
	var f = File.new()
	if f.open(profile_path % profile_name, File.WRITE) != OK:
		push_error("Couldn't save profile!")
		return
	f.store_string(whole_string)
	f.close()

func is_action_pressed(action: String) -> bool:
	for possibility in profiles[current_profile][action]:
		if [possibility[0], ActionStatus.PRESSED, possibility[1]] in events:
			return true
	return false

func is_action_released(action: String) -> bool:
	for possibility in profiles[current_profile][action]:
		if [possibility[0], ActionStatus.RELEASED, possibility[1]] in events:
			return true
	return false

func is_action_just_pressed(action: String) -> bool:
	for possibility in profiles[current_profile][action]:
		if [possibility[0], ActionStatus.PRESSED, possibility[1]] in new_events:
			return true
	return false

func is_action_just_released(action: String) -> bool:
	for possibility in profiles[current_profile][action]:
		if [possibility[0], ActionStatus.RELEASED, possibility[1]] in new_events:
			return true
	return false
