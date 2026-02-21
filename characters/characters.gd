extends Node

const character_file = "res://characters/%s/character.txt"
const desc_path = "res://characters/%s/description/%s.txt"
const picture_paths = "res://characters/%s/images/%s.png"

var characters = {}
var playable_characters = []

class Character:
	var _path: String = ""

	var _name: Dictionary = {}
	var name: String = ""

	var _fighter_class: Dictionary = {}
	var fighter_class: String = ""

	var skilltree: Skills.Skilltree

	var xp: int = 0

	var playable_on: int = -1

	var _weapon_name: String = ""
	var _weapon: Dictionary = {}
	var weapon: String = ""

	var _skill: Dictionary = {}
	var skill: String = ""

	var stats: Dictionary = {}

	var _fully_instantiated: bool = false

	func _init(character):
		self._path = character
		var f = File.new()
		if not f.file_exists(character_file % character):
			push_error("Character '%s' doesn't exist!" %(character))
			return
		self.skilltree = Skills.get_skilltree(character)
		f.open(character_file % character, File.READ)
		var lines = f.get_as_text().split("\n")
		f.close()
		for line in lines:
			if line.begins_with("- "):
				line = line.right(2).split(": ")
				if line[0] == "playable":
					if line[1] == "no":
						self.playable_on = -1
				elif line[0] == "playable_with":
					self.playable_on = int(line[1])
				elif line[0] == "weapon":
					self._weapon_name = line[1]
				else:
					self.stats[line[0]] = line[1]
		for lang in Locale.locales:
			if f.open(desc_path % [self._path, lang], File.READ) != OK:
				push_error("Couldn't open desc file '%s/%s'!" % [self._path, lang])
				return
			lines = f.get_as_text().split("\n")
			f.close()
			for line in lines:
				if line.begins_with("- "):
					line = line.right(2)
					var key = line.split(": ")[0]
					var value = line.split(": ")[1]
					if key == "name":
						self._name[lang] = value
					elif key == "class":
						self._fighter_class[lang] = value
					elif key == "weapon":
						self._weapon[lang] = value
					elif key == "skill":
						self._skill[lang] = value
					else:
						push_warning("Descriptor '%s' found, but not used!" % key)
		set_lang(Locale.lang)
		self._fully_instantiated = true

	func set_lang(lang: String):
		self.fighter_class = self._fighter_class[lang]
		self.name = self._name[lang]
		self.weapon = self._weapon[lang]
		self.skill = self._skill[lang]

	func get_picture(pose: String) -> Texture:
		if not self._fully_instantiated:
			push_error("Not instantiated correctly!")
		return load(picture_paths % [self._path, pose]) as Texture

	func to_bbcode() -> String:
		if not self._fully_instantiated:
			push_error("Not instantiated correctly!")
		var out = "[center][jump_pulse]" + self.name + "[/jump_pulse][/center]"
		out += "\n[center][font=res://assets/fonts/Jacquard_24/FontMedium.tres][jump_pulse]"
		out += self.fighter_class
		out += "[/jump_pulse][/font][/center]"
		return out

func get_character(character_name) -> Character:
	if character_name in characters:
		return characters[character_name]
	characters[character_name] = Character.new(character_name)
	return characters[character_name]

func init():
	if not Locale.locales:
		push_error("Locale not ready, might result in chaos!")
	var f = File.new()
	f.open("res://characters/characters.txt", File.READ)
	var content = f.get_as_text().split("\n")
	f.close()
	for line in content:
		if line:
			var character = get_character(line)
			if character.playable_on > -1:
				playable_characters.append(line)
