extends Control

const character_selector = preload("res://ui/CharacterSelector.tscn")

func _ready():
	Modulate.hide_everything()
	Locale.init()
	Characters.init()
	$SpecialMenu/VButtonMenu/DeveloperButton.disabled = not OS.has_feature("developer")
	$MainMenu/VButtonMenu.activate()
	$MainMenu.rect_position = Vector2(412, 100)
	Modulate.fade_in()
	for character in Characters.playable_characters:
		var instance = character_selector.instance()
		instance.character_name = character
		$CharacterSelection/CenterContainer/HButtonMenu.add_child(instance)
	$CharacterSelection/CenterContainer/HButtonMenu.update()
	var f = File.new()
	f.open("res://credits.txt", File.READ)
	var content = "\n[jump_pulse]" + f.get_as_text() + "[jump_pulse]"
	f.close()
	$Credits.bbcode_text = content
	$Stars.rect_size.y += $Credits.rect_size.y + 700
	$Stars.redraw()
	var button_texts = Locale.get_menu_labels()
	var i
	for menu in button_texts:
		var menu_node = get_node(menu + "Menu").get_child(0)
		i = 0
		for button in menu_node.get_children():
			button.text = button_texts[menu][i]
			i += 1
	for language in Locale.locales:
		var button = UIButton.new()
		button.text = Locale.locales[language]
		button.connect("button_down", self, "select_language", [language])
		$LanguageMenu/VButtonMenu.add_child(button)
	$LanguageMenu/VButtonMenu/BackButton.raise()
	$LanguageMenu/VButtonMenu.update()

func _on_PlayButton_button_down():
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(-200, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($CharacterSelection, "rect_position", null, Vector2(0, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$CharacterSelection/CenterContainer/HButtonMenu.activate(1)

func _on_CharacterSelection_BackButton_button_down():
	$Tween.interpolate_property($CharacterSelection, "rect_position", null, Vector2(1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$MainMenu/VButtonMenu.activate()

func _on_ExitButton_button_down():
	get_tree().quit()

func _on_SpecialButton_button_down():
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(-200, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($SpecialMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$SpecialMenu/VButtonMenu.activate()

func _on_BackButton_button_down():
	$Tween.interpolate_property($SpecialMenu, "rect_position", null, Vector2(1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($SettingsMenu, "rect_position", null, Vector2(1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$MainMenu/VButtonMenu.activate()

func _on_SettingsButton_button_down():
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(-200, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($SettingsMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$SettingsMenu/VButtonMenu.activate()

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

func _on_LanguageButton_button_down():
	$Tween.interpolate_property($SettingsMenu, "rect_position", null, Vector2(-200, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($LanguageMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$LanguageMenu/VButtonMenu.activate()

func _on_LanguageMenu_BackButton_button_down():
	$Tween.interpolate_property($LanguageMenu, "rect_position", null, Vector2(1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($SettingsMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$SettingsMenu/VButtonMenu.activate()

func select_language(lang: String):
	Modulate.fade_out()
	yield(Modulate, "finished")
	Locale.lang = lang
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ui/Main.tscn")
