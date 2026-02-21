tool

extends HBoxContainer
class_name HButtonMenu

var active = false

var buttons: Array = []
var buttons_to_enable = []
var selected: int = 0

func update():
	buttons = []
	var i = 0
	for child in get_children():
		child.id = i
		if not child.is_connected("button_up", self, "deactivate"):
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
		if not button.disabled:
			buttons_to_enable.append(button)
		button.disabled = true

func _ready():
	update()

func activate(to_select: int = 0):
	if active:
		return
	active = true
	for button in buttons_to_enable:
		button.disabled = false
	if to_select >= len(buttons):
		to_select = 0
	selected = to_select
	if buttons[to_select].disabled:
		for i in range(len(buttons)):
			if not buttons[i].disabled:
				selected = i
				break
	buttons[selected].focused = true

func _process(_delta):
	if not buttons:
		update()
	if active and is_visible_in_tree():
		if Input.is_action_just_pressed("ui_right"):
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
		if Input.is_action_just_pressed("ui_left"):
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
