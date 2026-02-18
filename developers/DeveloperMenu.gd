extends Control

var scene

func _on_SkilltreeButton_pressed():
	Modulate.fade_out()
	yield(Modulate, "finished")
	scene = preload("res://assets/skilltree/Skilltree.tscn").instance()
	$MainContainer.hide()
	add_child(scene)
	$HUD.show()
	Modulate.fade_in()

func _on_ExitButton_pressed():
	Modulate.fade_out()
	yield(Modulate, "finished")
	scene.queue_free()
	$MainContainer.show()
	$HUD.hide()
	Modulate.fade_in()

func _on_LanguageSwitcher_locale_changed():
	Modulate.fade_out()
	yield(Modulate, "finished")
	var scene_filename = scene.filename
	scene.queue_free()
	yield(get_tree(), "idle_frame")
	scene = load(scene_filename).instance()
	add_child(scene)
	Modulate.fade_in()

