extends RichTextLabel

signal finished

export (float) var space_speed = 0.025
export (float) var character_speed = 0.05
export (float) var stop_speed = 0.2

var to_show
var time_elapsed
var character
var finished = true

func _ready():
	bbcode_enabled = true

func show_text(_text: String):
	finished = false
	time_elapsed = 0
	character = 0
	visible_characters = 0
	bbcode_text = "\n[center][jump_pulse]" + _text + "[/jump_pulse][/center]"
	to_show = _text

func _process(delta):
	if not finished:
		time_elapsed += delta
		match to_show[character]:
			"":
				if time_elapsed > space_speed:
					time_elapsed -= space_speed
					visible_characters += 1
					character += 1
			[".", ",", "!", "?"]:
				if time_elapsed > stop_speed:
					time_elapsed -= stop_speed
					visible_characters += 1
					character += 1
			_:
				if time_elapsed > character_speed:
					time_elapsed -= stop_speed
					visible_characters += 1
					character += 1
		if character == len(to_show):
			finished = true
			emit_signal("finished")
