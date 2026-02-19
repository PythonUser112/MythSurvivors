tool

extends Control
class_name UIButton

signal button_down
signal button_up

export (String) var text

export (Color) var disabled_color = Color(0, 0, 0)
export (Color) var normal_color = Color(0.35, 0.35, 0.35)
export (Color) var focus_color = Color(0.5, 0.5, 0.5)
export (Color) var pressed_color = Color(0.75, 0.75, 0.75)

export (Vector2) var margin = Vector2(20, 20)

export (bool) var focused
export (bool) var disabled
var pressed

var color_rect
var label
var jump_pulse

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	rect_min_size = Vector2(100, 60) + 2 * margin
	color_rect = ColorRect.new()
	color_rect.color = disabled_color
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.rect_position = margin
	color_rect.pause_mode = PAUSE_MODE_PROCESS
	add_child(color_rect)
	label = RichTextLabel.new()
	label.rect_min_size = Vector2(100, 60)
	jump_pulse = JumpPulse.new()
	label.install_effect(jump_pulse)
	label.rect_position = margin
	label.scroll_active = false
	label.bbcode_enabled = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	label.bbcode_text = "\n[center][jump_pulse]" + text + "[/jump_pulse][/center]"
	label.pause_mode = PAUSE_MODE_PROCESS
	add_child(label)

func _gui_input(event):
	if event is InputEventMouseMotion:
		focused = event.position > margin and event.position < rect_size - margin and not disabled
	if focused:
		if event is InputEventMouseButton and event.pressed or Input.is_action_just_pressed("select"):
			pressed = true
			emit_signal("button_down")
		if event is InputEventMouseButton and not event.pressed or Input.is_action_just_released("select"):
			pressed = false
			emit_signal("button_up")

func _process(_delta):
	if focused:
		if Input.is_action_just_pressed("ui_accept"):
			pressed = true
			emit_signal("button_down")
		if Input.is_action_just_released("ui_accept"):
			pressed = false
			emit_signal("button_up")
	if disabled:
		color_rect.color = disabled_color
	elif pressed:
		color_rect.color = pressed_color
	elif focused:
		color_rect.color = focus_color
	else:
		color_rect.color = normal_color
	color_rect.rect_size = rect_size - margin * 2
	label.rect_size = rect_size - margin * 2
