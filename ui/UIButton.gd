tool

extends Control
class_name UIButton

signal button_down
signal button_up
signal focused

export (String) var text
var old_text

export (int) var id

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
var label_container
var jump_pulse

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	if rect_min_size < Vector2(100, 60) + 2 * margin:
		rect_min_size = Vector2(100, 60) + 2 * margin
	if rect_min_size.x < 180:
		rect_min_size.x = 180
	color_rect = ColorRect.new()
	color_rect.color = disabled_color
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.rect_position = margin
	color_rect.pause_mode = PAUSE_MODE_PROCESS
	add_child(color_rect)
	label_container = CenterContainer.new()
	label_container.rect_position = margin
	label_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label = RichTextLabel.new()
	label.rect_min_size = Vector2(100, 60)
	label.fit_content_height = true
	jump_pulse = JumpPulse.new()
	label.install_effect(jump_pulse)
	label.scroll_active = false
	label.bbcode_enabled = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	label.bbcode_text = "\n[center][jump_pulse]" + text + "[/jump_pulse][/center]"
	label.pause_mode = PAUSE_MODE_PROCESS
	label_container.add_child(label)
	add_child(label_container)
	old_text = text

func _gui_input(event):
	if event is InputEventMouseMotion:
		if event.position > margin and event.position < rect_size - margin and not disabled:
			focused = true
			emit_signal("focused", id)
		else:
			focused = false
	if focused:
		if event is InputEventMouseButton and event.pressed:
			print_debug("Pressed")
			pressed = true
			emit_signal("button_down")
	if event is InputEventMouseButton and not event.pressed and pressed:
		pressed = false
		emit_signal("button_up")

func _process(_delta):
	if color_rect == null:
		_ready()
	if old_text != text:
		label.bbcode_text = "\n[center][jump_pulse]" + text + "[/jump_pulse][/center]"
		old_text = text
	if focused:
		if Input.is_action_just_pressed("ui_accept"):
			pressed = true
			emit_signal("button_down")
	if Input.is_action_just_released("ui_accept") and pressed:
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
	label_container.rect_min_size.y = label.rect_size.y
	rect_min_size.y = label.rect_size.y + 2 * margin.y
	color_rect.rect_size = rect_size - margin * 2
	label_container.rect_size = rect_size - margin * 2
