tool

extends RichTextEffect
class_name JumpPulse

var bbcode = "jump_pulse"

func _ready():
	pass

func _process_custom_fx(char_fx):
	var amp = char_fx.env.get("amp", 25)
	var freq = char_fx.env.get("freq", 1)
	var uptime = char_fx.env.get("uptime", 0.25)
	var shift = char_fx.env.get("shift", 0.2)
	var charno = char_fx.relative_index
	var pos_y = max(0, amp * (sin(freq * char_fx.elapsed_time * PI * 2 - shift * charno) - 1 + uptime))
	char_fx.offset = Vector2(0, -1) * pos_y
	return true
