extends Control

export (String) var data_file

func show():
	$Dialog.hide()
	$Dialog.dialog_file = data_file
	$Tween.stop_all()
	$Tween.interpolate_property($CutscenePanel, "modulate", Color(0, 0, 0), Color(1, 1, 1), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	.show()
	yield($Tween, "tween_all_completed")
	$Dialog.run()
	yield($Dialog, "dialog_finished")
	$Dialog.hide()

func hide():
	$Tween.stop_all()
	$Tween.interpolate_property($CutscenePanel, "modulate", Color(1, 1, 1), Color(0, 0, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "finished")
	.hide()
