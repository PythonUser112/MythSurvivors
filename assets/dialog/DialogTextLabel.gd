extends RichTextLabel

signal finished

var time_elapsed
var characters = 0

func show_text(_text: String):
	time_elapsed = 0
	var count = _text.count("<<")
	var show_text = ""
	var index = 0
	var last_index = 0
	characters = 0
	visible_characters = 0
	bbcode_text = ""
	append_bbcode("[center][jump_pulse]")
	for _i in range(count):
		index = _text.find("<<", index)
		append_bbcode(_text.substr(last_index, index - last_index))
		characters += index - last_index 
		last_index = _text.find(">>", index)
		var action = _text.substr(index + 2, last_index - index - 2)
		var symbols = yield(InputManager.get_action_symbols(action), "completed")
		for sym in symbols:
			if sym is String:
				append_bbcode(sym)
				characters += len(sym)
			elif sym is Texture:
				add_image(sym)
				characters += 1
		index += 2
		last_index += 2
	characters += len(_text) - last_index
	show_text += _text.substr(last_index)
	append_bbcode(show_text)
	$Timer.start(0.1)

func _on_Timer_timeout():
	if visible_characters < characters:
		visible_characters += 1
		if visible_characters == characters:
			$Timer.wait_time = characters / 10.0
	else:
		emit_signal("finished")

func _process(_delta):
	if Input.is_action_just_pressed("ui_select"):
		if visible_characters < characters:
			visible_characters = characters
			$Timer.stop()
		else:
			emit_signal("finished")
			$Timer.stop()
