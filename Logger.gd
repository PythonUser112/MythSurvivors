extends CanvasLayer

func _message(color: String, stage: String, part: String, message: String) -> void:
	var timestamp = OS.get_unix_time()
	$LoggerMessages.append_bbcode("[color=%s]%s %s: [color=#00ffff]%s[/color] %s[/color]\n" %[color, timestamp, stage, part, message])

func error(part: String, message: String) -> void:
	_message("red", "ERROR", part, message)
	push_error("%s: %s" % [part, message])

func warn(part: String, message: String) -> void:
	_message("yellow", "WARN ", part, message)
	push_warning("%s: %s" % [part, message])

func info(part: String, message: String) -> void:
	_message("white", "INFO ", part, message)

func debug(part: String, message: String) -> void:
	_message("grey", "DEBUG", part, message)
	print_debug("%s: %s" % [part, message])

func _ready():
	if Globals.config.get("auto_matrix_mode", "0") == "1":
		$LoggerMessages.modulate.a = 1

func _process(_delta):
	if Input.is_action_just_pressed("matrix_mode"):
		if $LoggerMessages.modulate.a:
			$Tween.interpolate_property($LoggerMessages, "modulate", null, Color(1, 1, 1, 0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			$Tween.start()
		else:
			$Tween.interpolate_property($LoggerMessages, "modulate", null, Color(1, 1, 1, 1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			$Tween.start()
