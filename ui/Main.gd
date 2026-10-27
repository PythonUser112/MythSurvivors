extends Control

export (Array, PackedScene) var levels = []

const character_selector = preload("res://ui/CharacterSelector.tscn")

func _ready():
	InputManager.connect("menu_closed", self, "_on_Settings_BackButton_button_down")
	OS.window_maximized = Globals.config["maximized"] == "1"
	$GraphicsMenu/VButtonMenu/MaximizedButton.down = Globals.config["maximized"] == "1"
	OS.window_fullscreen = Globals.config["fullscreen"] == "1"
	$GraphicsMenu/VButtonMenu/FullscreenButton.down = Globals.config["fullscreen"] == "1"
	$GraphicsMenu/VButtonMenu/ShaderButton.down = Globals.config["shaders"] == "1"
	$GraphicsMenu/VButtonMenu/ShaderButton.down = Globals.config["textfx"] == "1"
	Modulate.hide_everything()
	$SpecialMenu/VButtonMenu/DeveloperButton.disabled = not Globals.developer_mode
	$MainMenu.rect_position = Vector2(412, 100)
	Modulate.fade_in()
	var f = File.new()
	f.open("res://credits.txt", File.READ)
	var content = "\n[jump_pulse]" + f.get_as_text() + "[jump_pulse]"
	f.close()
	$Credits.bbcode_text = content
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
	$MainMenu/VButtonMenu.activate()

func _on_PlayButton_button_down():
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(-250, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	yield($Tween, "tween_all_completed")

func _on_ExitButton_button_down():
	get_tree().quit()

func _on_SpecialButton_button_down():
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(-250, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($SpecialMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$SpecialMenu/VButtonMenu.activate()

func _on_BackButton_button_down():
	$Tween.interpolate_property($SpecialMenu, "rect_position", null, Vector2(1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($SettingsMenu, "rect_position", null, Vector2(1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($GraphicsMenu, "rect_position", null, Vector2(1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($LanguageMenu, "rect_position", null, Vector2(1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$MainMenu/VButtonMenu.activate()

func _on_Settings_BackButton_button_down():
	$Tween.interpolate_property($GraphicsMenu, "rect_position", null, Vector2(1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($LanguageMenu, "rect_position", null, Vector2(1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($SettingsMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$SettingsMenu/VButtonMenu.activate()

func _on_SettingsButton_button_down():
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(-250, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($SettingsMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$SettingsMenu/VButtonMenu.activate()

func _on_CreditButton_button_down():
	$Tween.interpolate_property($MainMenu, "rect_position", null, Vector2(412, -600), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Stars/Title, "rect_position", null, Vector2(0, -700), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Credits, "rect_position", null, Vector2(100, -$Credits.rect_size.y), 30, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$Credits.rect_position = Vector2(100, 600)
	$Stars/Title.rect_position = Vector2(0, 0)
	$Tween.interpolate_property($MainMenu, "rect_position", Vector2(412, -500 - $Credits.rect_size.y), Vector2(412, 100), 10, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$MainMenu/VButtonMenu.activate()

func _on_DeveloperButton_button_down():
	Modulate.fade_out()
	yield(Modulate, "finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://developers/DeveloperMenu.tscn")

func _on_LanguageButton_button_down():
	$Tween.interpolate_property($SettingsMenu, "rect_position", null, Vector2(-250, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($LanguageMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$LanguageMenu/VButtonMenu.activate()

func select_language(lang: String):
	Modulate.fade_out()
	yield(Modulate, "finished")
	Locale.set_locale(lang)
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ui/Main.tscn")

func _on_TruthpediaButton_button_down():
	Modulate.fade_out()
	yield(Modulate, "finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://truthpedia/Wiki.tscn")

func _on_BindingsButton_button_up():
	$Tween.interpolate_property($SettingsMenu, "rect_position", null, Vector2(-1024, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	InputManager.activate()

func _on_GraphicsButton_button_down():
	$Tween.interpolate_property($SettingsMenu, "rect_position", null, Vector2(-250, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($GraphicsMenu, "rect_position", null, Vector2(412, 100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 0.25)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	$GraphicsMenu/VButtonMenu.activate()

func _on_FullscreenButton_toggled(button_pressed: bool):
	Globals.update_config({"fullscreen": str(int(button_pressed))})
	OS.window_fullscreen = button_pressed

func _on_MaximizedButton_toggled(button_pressed: bool):
	Globals.update_config({"maximized": str(int(button_pressed))})
	OS.window_maximized = button_pressed

func _on_ShaderButton_toggled(button_pressed):
	if not button_pressed:
		$ShaderConfirmationDialog.popup_centered()
	else:
		Globals.update_config({"shaders": "1"})
		$CanvasLayer/Stars.redraw()

func _on_ShaderConfirmationDialog_confirmed():
	Globals.update_config({"shaders": "0"})
	$CanvasLayer/Stars.redraw()

func _on_ShaderConfirmationDialog_popup_hide():
	yield(get_tree(), "idle_frame")
	$GraphicsMenu/VButtonMenu/ShaderButton.down = Globals.config["shaders"] == "1"
