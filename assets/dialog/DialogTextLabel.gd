extends RichTextLabel

signal finished

var time_elapsed
var character

func show_text(_text: String):
	time_elapsed = 0
	character = 0
	visible_characters = 0
	var count = _text.count("<<")
	var show_text = ""
	var characters = 0
	var index = 0
	var last_index = 0
	for i in range(count):
		index = _text.find("<<", index)
		show_text += _text.substr(last_index, index - last_index)
		characters += index - last_index 
		last_index = _text.find(">>", index)
		var action = _text.substr(index + 2, last_index - index - 2)
		show_text += InputManager.get_action_symbols(action)
		index += 2
		last_index += 2
	characters += len(_text) - last_index
	show_text += _text.substr(index + 2)
	print(show_text, " ", characters)
	bbcode_text = "\n[center][jump_pulse][slow_show]" + show_text + "[/slow_show][/jump_pulse][/center]"
	$Timer.start(0.2 * characters + 0.1)

func _on_Timer_timeout():
	emit_signal("finished")
