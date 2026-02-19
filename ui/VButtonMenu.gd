tool

extends VBoxContainer
class_name VButtonMenu

var active = false

var buttons: Array = []
var selected: int = 0

func update():
	buttons = []
	for child in get_children():
		if not child.is_connected("button_down", self, "deactivate"):
			child.connect("button_up", self, "deactivate")
		buttons.append(child)

func deactivate():
	active = false
	buttons[selected].focused = false

func _ready():
	update()

func activate():
	if active:
		return
	active = true
	for i in range(len(buttons)):
		if not buttons[i].disabled:
			buttons[i].focused = true
			selected = i
			break

func _process(_delta):
	if active and is_visible_in_tree():
		if Input.is_action_just_pressed("ui_down"):
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
		if Input.is_action_just_pressed("ui_up"):
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
