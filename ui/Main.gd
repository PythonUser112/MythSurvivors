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
	var f = File.new()
	f.open("res://credits.txt", File.READ)
	var content = "\n[jump_pulse]" + f.get_as_text() + "[jump_pulse]"
	f.close()
	$Credits.bbcode_text = content
	$Stars.rect_size.y += $Credits.rect_size.y + 700
	$Stars.redraw()

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

func _on_CreditButton_button_down():
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(412, -600), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Stars/Title, "rect_position", null, Vector2(0, -700), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Credits, "rect_position", null, Vector2(100, -$Credits.rect_size.y), 30, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1)
	$Tween.interpolate_property($Stars, "rect_position", null, Vector2(0, -600 - $Credits.rect_size.y), 30, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$Credits.rect_position = Vector2(100, 600)
	$Stars/Title.rect_position = Vector2(0, 0)
	$Tween.interpolate_property($MainMenu, "rect_position", Vector2(412, -500 - $Credits.rect_size.y), Vector2(412, 100), 10, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Stars, "rect_position", Vector2(0, -600 - $Credits.rect_size.y), Vector2(0, 0), 10, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$MainMenu/VButtonMenu.activate()

func _on_DeveloperButton_button_down():
	Modulate.fade_out()
	yield(Modulate, "finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://developers/DeveloperMenu.tscn")
