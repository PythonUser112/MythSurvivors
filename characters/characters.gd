extends Node

const character_file = "res://characters/%s/character/%s.txt"
var characters = {}

class Character:
	var name: String = "Test"
	var short_desc: String = "Testtesttest"
	var skilltree: Skills.Skilltree
	var xp: int = 0
	var stats: Dictionary = {}

	func _init(character):
		var f = File.new()
		if not f.file_exists(character_file % [character, Locale.lang]):
			push_error("Character '%s' doesn't exist!" %(character))
		self.skilltree = Skills.get_skilltree(character)

	func to_bbcode():
		var out = "[center][jump_pulse]" + self.name + "[/jump_pulse][/center]"
		out += "\n[center][font=res://assets/fonts/Jacquard_24/FontMedium.tres][jump_pulse]"
		out += self.short_desc
		out += "[/jump_pulse][/font][/center]"
		return out

func get_character(character_name):
	if character_name in characters:
		return characters[character_name]
	characters[character_name] = Character.new(character_name)
	return characters[character_name]
