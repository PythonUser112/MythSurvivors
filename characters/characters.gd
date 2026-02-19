extends Node

const character_file = "res://characters/%s/character.txt"
const picture_paths = "res://characters/%s/images/%s.png"
var characters = {}
var playable_characters = []

class Character:
	var _name: String = ""
	var name: String = ""
	var short_desc: String = ""
	var skilltree: Skills.Skilltree
	var xp: int = 0
	var playable_on: int = -1
	var weapon: String = ""
	var weapon_translated: String = ""
	var stats: Dictionary = {}
	var _fully_instantiated: bool = false

	func _init(character):
		self._name = character
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
					self.weapon = line[1]
				else:
					self.stats[line[0]] = line[1]
		self._fully_instantiated = true

	func get_picture(pose):
		if not self._fully_instantiated:
			return
		return load(picture_paths % [self._name, pose])

	func to_bbcode() -> String:
		var out = "[center][jump_pulse]" + self.name + "[/jump_pulse][/center]"
		out += "\n[center][font=res://assets/fonts/Jacquard_24/FontMedium.tres][jump_pulse]"
		out += self.short_desc
		out += "[/jump_pulse][/font][/center]"
		return out

func get_character(character_name) -> Character:
	if character_name in characters:
		return characters[character_name]
	characters[character_name] = Character.new(character_name)
	return characters[character_name]

func _ready():
	var f = File.new()
	f.open("res://characters/characters.txt", File.READ)
	var content = f.get_as_text().split("\n")
	f.close()
	for line in content:
		if line:
			var character = get_character(line)
			if character.playable_on > -1:
				playable_characters.append(line)
