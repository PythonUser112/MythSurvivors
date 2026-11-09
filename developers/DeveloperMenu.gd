extends Control

var scene

func _ready():
	Logger.info("Developer Menu", "Developer Menu loaded")
	Modulate.fade_in()
	yield(Modulate, "finished")
	$MainContainer/CenterContainer/VButtonMenu.activate()

func _on_ExitButton_pressed():
	Modulate.fade_out()
	yield(Modulate, "finished")
	scene.queue_free()
	$MainContainer.show()
	Modulate.fade_in()
	yield(Modulate, "finished")

func _on_BackButton_button_down():
	Logger.info("Developer Menu", "Leaving Developer Menu")
	Modulate.fade_out()
	yield(Modulate, "finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ui/Main.tscn")

func _on_TruthpediaEditor_button_down():
	Logger.info("Developer Menu", "Entering TruthPedia")
	Modulate.fade_out()
	yield(Modulate, "finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://developers/WikiPageCreator.tscn")

func _on_TestButton_button_down():
	Logger.info("Developer Menu", "Entering TestManager")
	Modulate.fade_out()
	yield(Modulate, "finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://tests/TestManager.tscn")
