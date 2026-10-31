extends Control

onready var locales: Array = Locale.locales.keys()
var locale_selected = false
var devil_checker_found = false
var newsletter_checker_found = false
const STDCONF = {
	"lang": "en",
	"shaders": "1",
	"textfx": "1",
	"fullscreen": "0",
	"maximized": "0",
	"developer": "0"
}
onready var targets = {
	"shaders": $ScrollContainer/GridContainer/ShaderChecker,
	"textfx": $ScrollContainer/GridContainer/TextfxChecker,
	"fullscreen": $ScrollContainer/GridContainer/FullscreenChecker,
	"maximized": $ScrollContainer/GridContainer/MaximizeStartupChecker,
	"developer": $ScrollContainer/GridContainer/DeveloperChecker
}

func _ready():
	var conf = STDCONF
	for key in conf:
		if Globals.config.has(key):
			conf[key] = Globals.config.get(key)
		if key in targets:
			targets[key].pressed = conf[key] == "1"
	Globals.update_config(conf)
	for locale in locales:
		$ScrollContainer/GridContainer/LanguageButton.get_popup().add_item(Locale.locales[locale])
	if Globals.config.has("lang"):
		$ScrollContainer/GridContainer/LanguageButton.selected = locales.find(Globals.config.get("lang"))
		locale_selected = true
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
	Locale.init()

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
	Globals.update_config({"maximized": str(int(button_pressed))})

func _on_DevilChecker_toggled(_button_pressed: bool):
	devil_checker_found = true
	$ScrollContainer/GridContainer/DevilChecker.disabled = true

func _on_NewsletterChecker_toggled(_button_pressed: bool):
	newsletter_checker_found = true
	$ScrollContainer/GridContainer/NewsletterChecker.disabled = true

func _on_DeveloperChecker_toggled(button_pressed: bool):
	Globals.update_config({"developer": str(int(button_pressed))})

func _on_MatrixChecker_toggled(button_pressed):
	Globals.update_config({"auto_matrix_mode": str(int(button_pressed))})
