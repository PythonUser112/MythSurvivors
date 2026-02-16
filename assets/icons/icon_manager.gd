extends Node

var templates = [
	"res://assets/characters/%s/images/icon.png",
]

func get_icon(name: String) -> Texture:
	var f = File.new()
	for element in templates:
		if f.file_exists(element % name):
			return load(element % name) as Texture
	return null
