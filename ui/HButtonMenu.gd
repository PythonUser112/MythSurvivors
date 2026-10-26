tool

extends HBoxContainer
class_name HButtonMenu

export (bool) var deactivate_on_press = true
var active = false

var buttons: Array = []
var selected: int = 0

func update():
	buttons = []
	var i = 0
	for child in get_children():
		if child is VSeparator:
			continue
		child.id = i
		if not child.is_connected("button_up", self, "deactivate"):
			if not child.toggle_mode and deactivate_on_press:
				child.connect("button_up", self, "deactivate")
			child.connect("focused", self, "focus_changed")
		buttons.append(child)
		i += 1

func focus_changed(id):
	if id != selected:
		buttons[selected].focused = false
		selected = id

func deactivate():
	active = false
	buttons[selected].focused = false
	for button in buttons:
		button.deactivated = true

func _ready():
	update()

func activate(to_select: int = 0):
	if active:
		return
	active = true
	for button in buttons:
		button.deactivated = false
	selected = to_select
	if buttons[to_select].disabled:
		for i in range(len(buttons)):
			if not buttons[i].disabled:
				selected = i
				break
	buttons[selected].focused = true
	if get_parent() is ScrollContainer:
		get_parent().ensure_control_visible(buttons[selected])

func _process(_delta):
	if not buttons:
		update()
	if active and is_visible_in_tree():
		if Input.is_action_just_pressed("ui_home"):
			buttons[selected].focused = false
			selected = 0
			while buttons[selected].disabled:
				selected += 1
			buttons[selected].focused = true
		if Input.is_action_just_pressed("ui_end"):
			buttons[selected].focused = false
			selected = len(buttons) - 1
			while buttons[selected].disabled:
				selected -= 1
			buttons[selected].focused = true
		if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_focus_next"):
			buttons[selected].focused = false
			selected += 1
			if selected == len(buttons):
				selected -= 1
			while buttons[selected].disabled:
				selected += 1
				if selected == len(buttons):
					selected -= 1
					while buttons[selected].disabled:
						selected -= 1
					break
			buttons[selected].focused = true
			if get_parent() is ScrollContainer:
				get_parent().ensure_control_visible(buttons[selected])
		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_focus_prev"):
			buttons[selected].focused = false
			selected -= 1
			if selected < 0:
				selected += 1
			while buttons[selected].disabled:
				selected -= 1
				if selected < 0:
					selected += 1
					while buttons[selected].disabled:
						selected += 1
					break
			buttons[selected].focused = true
			if get_parent() is ScrollContainer:
				get_parent().ensure_control_visible(buttons[selected])
