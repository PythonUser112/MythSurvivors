extends Control

var scene

func _on_SkilltreeButton_pressed():
	scene = preload("res://assets/skilltree/Skilltree.tscn").instance()
	$MainContainer.hide()
	add_child(scene)
	$HUD.show()

func _on_ExitButton_pressed():
	scene.queue_free()
	$MainContainer.show()
	$HUD.hide()

func _on_LanguageSwitcher_locale_changed():
	var scene_filename = scene.filename
	scene.queue_free()
	yield(get_tree(), "idle_frame")
	scene = load(scene_filename).instance()
	add_child(scene)
