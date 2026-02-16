extends Node

export (String) var skilltree_path = "res://characters/%s/skilltree/%s.txt"

var skilltrees = {}

const colors = {
	"white": Color(1, 1, 1),
	"red": Color(1, 0, 0),
	"yellow": Color(1, 1, 0),
	"green": Color(0, 1, 0),
	"cyan": Color(0, 1, 1),
	"blue": Color(0, 0, 1),
	"purple": Color(1, 0, 1),
}

class Skilltree:
	var skills_ordered = []
	var skill_attributes = {}
	var skill_deps = {}

	func get_skill_order(skill: String) -> int:
		var order = 0
		var i = 0
		for group in skills_ordered:
			if skill in group:
				return i
			i += 1
		if skill_deps[skill]:
			for dep in skill_deps[skill]:
				if dep != "":
					if not dep in skill_deps:
						pass
					var dep_order = get_skill_order(dep)
					if dep_order >= len(skills_ordered):
						for _i in range(dep_order - len(skills_ordered) + 1):
							skills_ordered.append([])
					var add = true
					for group in skills_ordered:
						if dep in group:
							add = false
							break
					if add:
						skills_ordered[dep_order].append(dep)
					order = max(order, dep_order + 1)
		return order

	func _init(skilltree_filename):
		var f = File.new()
		f.open(skilltree_filename, File.READ)
		var content = f.get_as_text()
		f.close()
		var current_skill
		for line in content.split("\n"):
			if not line:
				continue
			if line.begins_with("-"):
				line = line.right(2)
				var attribute = line.split(":")[0].lstrip(" ")
				var value = line.split(":")[1].lstrip(" ")
				if attribute == "dep":
					skill_deps[current_skill].append(value)
				else:
					if attribute != "color":
						value = int(value)
					skill_attributes[current_skill][attribute] = value
			else:
				current_skill = line.split(":")[0]
				skill_attributes[current_skill] = {}
				skill_deps[current_skill] = []
		for skill in skill_deps:
			var order = get_skill_order(skill)
			var add = true
			for group in skills_ordered:
				if skill in group:
					add = false
					break
			if add:
				if order >= len(skills_ordered):
					for _i in range(order - len(skills_ordered) + 1):
						skills_ordered.append([])
				skills_ordered[order].append(skill)
		if len(skills_ordered[0]) > 1:
			push_warning("Skilltree '%s' should contain only one root item." % (skilltree_filename))

	func get_skill_color(skill):
		return colors[skill_attributes[skill]["color"]]

	func get_skill_deps(skill):
		return skill_deps[skill]

	func is_skill_active(_skill):
		push_warning("Skilltree.is_skill_active not defined yet!")
		return false

	func unlockable(skill):
		for dep in get_skill_deps(skill):
			if not is_skill_active(dep):
				return false
		return true

	func get_skill_attributes(skill):
		var bonuses = {}
		for attribute in skill_attributes[skill]:
			if not attribute in ["cost", "color"]:
				bonuses[attribute] = skill_attributes[skill][attribute]
		return bonuses
	
	func get_skill_cost(skill):
		return skill_attributes[skill]["cost"]

func get_skilltree(character):
	if character in skilltrees:
		return skilltrees[character]
	skilltrees[character] = Skilltree.new(skilltree_path % [character, Locale.lang])
	return skilltrees[character]
