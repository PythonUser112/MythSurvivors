tool

extends RichTextEffect
class_name SlowShow

var bbcode = "slow_show"

func _process_custom_fx(char_fx):
	var show_duration = char_fx.env.get("show_duration", 0.2)
	var show_sleep = char_fx.env.get("show_sleep", 0.1)
	var charno = char_fx.relative_index
	var factor = max(min((char_fx.elapsed_time - show_sleep * charno) / show_duration, 1), 0)
	char_fx.visible = factor > 0
	char_fx.color.a = factor
	return true
