extends Control

onready var locales = Locale.locales.keys()
var locale_selected = false
var devil_checker_found = false
var newsletter_checker_found = false

func _ready():
	Globals.update_config({"shaders": "1", "textfx": "1", "fullscreen": "0", "maximize": "0"})
	for locale in locales:
		$ScrollContainer/GridContainer/LanguageButton.get_popup().add_item(Locale.locales[locale])
	Modulate.fade_in()

func _process(_delta):
	$ScrollContainer/GridContainer/ConfirmButton.disabled = not (locale_selected and devil_checker_found and newsletter_checker_found)

func _on_ConfirmButton_button_up():
	Globals.update_config({"config_version": Globals.version})
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ui/BootSplash.tscn")

func language_selected(index: int):
	locale_selected = true
	Globals.update_config({"lang": locales[index]})

func _on_ShaderChecker_toggled(button_pressed: bool):
	Globals.update_config({"shaders": str(int(button_pressed))})

func _on_TextfxChecker_toggled(button_pressed: bool):
	Globals.update_config({"textfx": str(int(button_pressed))})

func _on_FullscreenChecker_toggled(button_pressed: bool):
	Globals.update_config({"fullscreen": str(int(button_pressed))})
	if button_pressed:
		Globals.update_config({"maximize": "0"})
		$ScrollContainer/GridContainer/MaximizeStartupChecker.disabled = true
	else:
		Globals.update_config({"maximize": str(int($ScrollContainer/GridContainer/MaximizeStartupChecker.pressed))})
		$ScrollContainer/GridContainer/MaximizeStartupChecker.disabled = false

func _on_MaximizeStartupChecker_toggled(button_pressed: bool):
	Globals.update_config({"maximize": str(int(button_pressed))})

func _on_DevilChecker_toggled(_button_pressed: bool):
	devil_checker_found = true
	$ScrollContainer/GridContainer/DevilChecker.disabled = true

func _on_NewsletterChecker_toggled(_button_pressed: bool):
	newsletter_checker_found = true
	$ScrollContainer/GridContainer/NewsletterChecker.disabled = true
