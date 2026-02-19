extends Node

const character_file = "res://characters/%s/character.txt"
var characters = {}

class Character:
	var name: String = ""
	var short_desc: String = ""
	var skilltree: Skills.Skilltree
	var xp: int = 0
	var playable_on: int = -1
	var weapon: String = ""
	var weapon_translated: String = ""
	var stats: Dictionary = {}

	func _init(character):
		var f = File.new()
		if not f.file_exists(character_file % character):
			push_error("Character '%s' doesn't exist!" %(character))
		self.skilltree = Skills.get_skilltree(character)
		f.open(character_file % character, File.READ)
		var lines = f.get_as_text().split("\n")
		f.close()
		for line in lines:if line.begins_with("- "):
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
		print(stats)

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
