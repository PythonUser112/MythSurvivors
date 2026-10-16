extends RichTextLabel

signal finished

var characters = 0
var finished = false

func show_text(_text: String):
	hide()
	finished = false
	var count = _text.count("<<")
	var show_text = ""
	var index = 0
	var last_index = 0
	characters = 0
	bbcode_text = ""
# warning-ignore:return_value_discarded
	append_bbcode("[center]")
	for _i in range(count):
		index = _text.find("<<", index)
# warning-ignore:return_value_discarded
		append_bbcode(_text.substr(last_index, index - last_index))
		characters += index - last_index 
		last_index = _text.find(">>", index)
		var action = _text.substr(index + 2, last_index - index - 2)
		var symbols = yield(InputManager.get_action_symbols(action), "completed")
		for sym in symbols:
			if sym is String:
# warning-ignore:return_value_discarded
				append_bbcode(sym)
				characters += len(sym)
			elif sym is Texture:
				add_image(sym)
				characters += 1
		index += 2
		last_index += 2
	characters += len(_text) - last_index
	show_text += _text.substr(last_index)
# warning-ignore:return_value_discarded
	append_bbcode(show_text)
	$Tween.interpolate_property(self, "visible_characters", 0, characters, characters * 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	show()

func _process(delta):
	if finished:
		return
	if Input.is_action_just_pressed("select"):
		if $Tween.is_active() and not finished:
			$Tween.stop_all()
			visible_characters = characters
			$Timer.wait_time = characters / 10.0
			$Timer.start()
		else:
			finished = true
			$Timer.stop()
			$Tween.interpolate_property(self, "visible_characters", null, 0, characters * 0.01, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
			yield($Tween, "tween_completed")
			emit_signal("finished")

func _on_Timer_timeout():
	$Tween.interpolate_property(self, "visible_characters", null, 0, characters * 0.01, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	emit_signal("finished")
