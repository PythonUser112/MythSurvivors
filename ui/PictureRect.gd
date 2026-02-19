extends Control

var side = 1

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			$Tween.interpolate_property(get_node("Side" + str(side)), "modulate", 
			null, Color(0, 0, 0, 1), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			get_node("Side" + str(side)).hide()
			side = 3 - side
			get_node("Side" + str(side)).modulate = Color(0, 0, 0, 1)
			get_node("Side" + str(side)).show()
			$Tween.interpolate_property(get_node("Side" + str(side)), "modulate", 
			null, Color(1, 1, 1, 1), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			$Tween.start()
