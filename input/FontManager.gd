extends Node

var GLOBALFONT = "Standard_by_LB"

var fonts = {}

func _ready():
	var file = File.new()
	file.open("res://input/Fonts.txt", File.READ)
	var lines = file.get_as_text().split("\n")
	var font_name
	for line in lines:
		if line.begins_with("Font"):
			font_name = line.split(" ")[1]
			fonts[font_name] = {" ":[0, 0, 0, 0, 0]}
		else:
			var character = line.split(" ")[0]
			var font_data = Array(line.split(" ")).slice(1, 8)
			if character:
				fonts[font_name][character] = font_data

func to_binary(intValue: int) -> Array:
	var binary: Array = []
	while intValue > 0:
		binary.push_front(intValue & 1)
		intValue = intValue >> 1
	return binary

func fill_list_front(list, length, fill):
	var out_list = []
	var diff = length - len(list)
	while diff:
		out_list.append(fill)
		diff -= 1
	return out_list + list

func render_character(font, character, x, y):
	var font_data = fonts[font][character]
	var xymap = []
	var rowy = 0
	for row in font_data:
		var row_bin = fill_list_front(to_binary(int(row)), 5, 0)
		for i in range(5):
			if row_bin[i]:
				xymap.append(Vector2(i+x, y+rowy))
		rowy += 1
	return xymap

func render(font, string, pos):
	var x = pos.x
	var y = pos.y
	var xymap = []
	for element in string:
		xymap += render_character(font, element, x, y)
		x += 6
	return xymap
