extends Control

const character_selector = preload("res://ui/CharacterSelector.tscn")

func _ready():
	$SpecialMenu/VButtonMenu/DeveloperButton.disabled = not OS.has_feature("developer")
	$MainMenu/VButtonMenu.activate()
	$MainMenu.rect_position = Vector2(412, 100)
	Modulate.fade_in()
	for character in Characters.playable_characters:
		var instance = character_selector.instance()
		instance.character_name = character
		$CharacterSelector/CenterContainer/HButtonMenu.add_child(instance)
	$CharacterSelector/CenterContainer/HButtonMenu.update()

func _on_PlayButton_button_down():
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(0, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CharacterSelector, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$CharacterSelector/CenterContainer/HButtonMenu.activate()


func _on_ExitButton_button_down():
	get_tree().quit()

func _on_SpecialButton_button_down():
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(0, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($SpecialMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$SpecialMenu/VButtonMenu.activate()

func _on_BackButton_button_down():
	$Tween.interpolate_property($SpecialMenu, "rect_position", null, Vector2(1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$MainMenu/VButtonMenu.activate()

func _on_SettingsButton_button_down():
	pass # Replace with function body.

func _on_DeveloperButton_button_down():
	Modulate.fade_out()
	yield(Modulate, "finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://developers/DeveloperMenu.tscn")
