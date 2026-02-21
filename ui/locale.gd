extends Node

export (String) var lang = "en"

var locales = {}
var stat_translations = {}

func set_locale(locale: String):
	for character_name in Characters.characters:
		Characters.get_character(character_name).set_lang(locale)
	Skills.skilltrees = {}
	lang = locale

func get_stat(stat: String) -> String:
	return stat_translations[lang][stat]

func get_menu_labels() -> Dictionary:
	var f = File.new()
	f.open("res://ui/menus/%s.txt" % lang, File.READ)
	var content = f.get_as_text().split("\n")
	f.close()
	var current
	var menu_labels = {}
	for line in content:
		if line.begins_with("- "):
			if not current:
				push_error("Label without menu!")
			else:
				menu_labels[current].append(line.right(2))
		else:
			if line:
				current = line
				menu_labels[current] = []
	return menu_labels

func init():
	var f = File.new()
	f.open("res://locales.txt", File.READ)
	var content = f.get_as_text().split("\n")
	for line in content:
		if ": " in line:
			locales[line.split(": ")[0]] = line.split(": ")[1]
	f.close()
	for locale in locales:
		f.open("res://characters/stats/%s.txt" % (locale), File.READ)
		content = f.get_as_text().split("\n")
		f.close()
		stat_translations[locale] = {}
		for line in content:
			line = line as String
			if ": " in line:
				var key_value = line.split(": ")
				stat_translations[locale][key_value[0]] = key_value[1]
