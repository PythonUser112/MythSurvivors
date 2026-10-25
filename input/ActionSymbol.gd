extends RichTextLabel

signal button_down
signal button_up
signal focused

export (Color) var disabled_color = Color(0, 0, 0)
export (Color) var normal_color = Color(0.35, 0.35, 0.35)
export (Color) var focus_color = Color(0.5, 0.5, 0.5)
export (Color) var pressed_color = Color(0.75, 0.75, 0.75)

export (int) var id

const disabled = false
const toggle_mode = false
export (bool) var focused = false
export (bool) var down = false
export (bool) var deactivated = false
var pressed

var color_rect: ColorRect

func _gui_input(event):
	if event is InputEventMouseMotion:
		if event.position >= Vector2.ZERO and event.position <= rect_size and not deactivated:
			focused = true
			emit_signal("focused", id)
		else:
			focused = false
	if focused:
		if event is InputEventMouseButton and event.pressed:
			pressed = true
			emit_signal("button_down")
		elif event is InputEventMouseButton and not event.pressed:
			pressed = false
			emit_signal("button_up")
	if event is InputEventMouseButton and not event.pressed and pressed:
		pressed = false

func _process(_delta):
	if not is_visible_in_tree():
		return
	if not color_rect:
		color_rect = ColorRect.new()
		color_rect.mouse_filter = MOUSE_FILTER_IGNORE
		color_rect.show_behind_parent = true
		add_child(color_rect)
	color_rect.rect_size = rect_size
	if focused:
		if Input.is_action_just_pressed("ui_accept"):
			pressed = true
			emit_signal("button_down")
	if Input.is_action_just_released("ui_accept") and pressed:
		pressed = false
		emit_signal("button_up")
	if pressed:
		color_rect.color = pressed_color
	elif focused:
		color_rect.color = focus_color
	else:
		color_rect.color = normal_color
