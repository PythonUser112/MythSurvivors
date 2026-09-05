extends "res://game/Character.gd"

export (int) var lives

func _process(_delta):
	for dir in directions:
		if Input.is_action_pressed(dir):
			move(dir)
