extends CanvasLayer

signal finished

func fade_out():
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP
	$Tween.interpolate_property($ColorRect, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	get_tree().paused = true

func fade_in():
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP
	$Tween.interpolate_property($ColorRect, "color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	get_tree().paused = true

func _on_Tween_tween_all_completed():
	get_tree().paused = false
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	emit_signal("finished")
