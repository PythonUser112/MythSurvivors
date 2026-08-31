extends "res://game/Character.gd"

func _process(_delta):
	for dir in directions:
		if Input.is_action_pressed(dir):
			move(dir)
