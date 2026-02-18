extends Node

export (String) var lang = "en"

var locales = {}
var stat_translations = {}
var language_select = {}

func set_locale(locale):
	Characters.characters = {}
	Skills.skilltrees = {}
	lang = locale

func get_stat(stat) -> String:
	return stat_translations[lang][stat]

func _ready():
	var f = File.new()
	f.open("res://locales.txt", File.READ)
	var content = f.get_as_text().split("\n")
	for line in content:
		if ": " in line:
			locales[line.split(": ")[0]] = line.split(": ")[1]
			language_select[line.split(": ")[0]] = line.split(": ")[2]
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
