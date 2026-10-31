extends "res://game/Character.gd"

var target_position: Vector2

func _next_step():
	if grid_position != target_position:
		var diff = target_position - grid_position
		var ydiff = diff.y
		var xdiff = diff.x
		var diridx = 2 + sign(xdiff)
		if ydiff >= xdiff:
			diridx = 1 + sign(xdiff)
			if move(diridx):
				return
			diridx = 2 + sign(xdiff)
# warning-ignore:return_value_discarded
		if not move(diridx):
			Logger.warn("NPC '%s'" % character, "Character '%s' stuck at %s, wanted to get to %s!" % [character, grid_position, target_position])
