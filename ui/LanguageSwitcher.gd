extends MenuButton

signal locale_changed

var langs = []

func change_lang(id):
	emit_signal("locale_changed")
	Locale.set_locale(langs[id])

func _ready():
	for lang in Locale.locales:
		langs.append(lang)
		get_popup().add_item(Locale.locales[lang])
	get_popup().connect("id_pressed", self, "change_lang")
