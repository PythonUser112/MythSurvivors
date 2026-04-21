extends Control

export (String) var wikipage
export (bool) var fail = false

const title = "\n[center][jump_pulse][font=res://assets/fonts/Jacquard_24/FontBig.tres]%s[/font][/jump_pulse][/center]"
const heading = "\n[center][jump_pulse][font=res://assets/fonts/Jacquard_24/FontMedium.tres]%s[/font][/jump_pulse][/center]"

var ypositions = {}

func _ready():
	var wiki = "res://truthpedia/wiki/" + wikipage + "/" + Locale.lang + ".md"
	var f = File.new()
	if not f.file_exists(wiki):
		push_error("Wikipage %s does not exist!" % wikipage)
		fail = true
		return
	f.open(wiki, File.READ)
	var content = f.get_as_text().split("\n")
	f.close()
	$PageTitle.bbcode_text = title % wikipage.capitalize()
	var image_part = false
	var bbcode_text = ""
	var part = ""
	for line in content:
		if line.begins_with("# "):
			if bbcode_text:
				var content_container = Control.new()
				var label = RichTextLabel.new()
				label.custom_effects = [JumpPulse.new()]
				label.fit_content_height = true
				label.bbcode_enabled = true
				label.scroll_active = false
				label.bbcode_text = bbcode_text
				label.rect_min_size.x = 774
				label.connect("meta_clicked", self, "_on_Content_meta_clicked")
				content_container.add_child(label)
				$ContentContainer/VBoxContainer.add_child(content_container)
				label.update()
				yield(get_tree(), "idle_frame")
				label.rect_min_size.y = label.rect_size.y
				content_container.name = part
				content_container.rect_min_size = label.rect_min_size
				ypositions[part] = label.rect_position.y
			part = line.right(2)
			image_part = true
			bbcode_text = heading % part
			continue
		if image_part:
			if line.begins_with("!["):
				push_warning("Image handling not supported!")
				var _path = line.split("(")[1].split(" ")[0]
				continue
			image_part = false
		if bbcode_text and not image_part:
			var line_parsed = ""
			var state = 0
			var tmp1
			var tmp2
			var crossed = false
			var last_was_space = false
			var oldstate = 0
			for character in line:
				if state == 0:
					if character == "[":
						state = 1
						line_parsed += "[url="
						tmp1 = ""
						tmp2 = ""
					elif character == "-":
						if crossed and not last_was_space:
							line_parsed += "[/s]"
							crossed = false
						elif not crossed:
							state = 3
					else:
						line_parsed += character
				elif state == 1:
					if character == "]":
						state = 2
					else:
						tmp1 += character
				elif state == 2:
					if character == ")":
						line_parsed += tmp2
						line_parsed += "]"
						line_parsed += tmp1
						line_parsed += "[/url]"
						state = 0
					elif character != "(":
						tmp2 += character
				elif state == 3:
					if character in [" ", "\n", "\t"]:
						line_parsed += "-"
					else:
						crossed = true
						line_parsed += "[s]"
					line_parsed += character
					state = 0
				last_was_space = character in [" ", "\n", "\t"]
			bbcode_text += "\n" + line_parsed
	if bbcode_text:
		var content_container = Control.new()
		var label = RichTextLabel.new()
		label.connect("meta_clicked", self, "_on_Content_meta_clicked")
		label.custom_effects = [JumpPulse.new()]
		label.fit_content_height = true
		label.bbcode_enabled = true
		label.scroll_active = false
		label.bbcode_text = bbcode_text
		label.rect_min_size.x = 774
		content_container.add_child(label)
		$ContentContainer/VBoxContainer.add_child(content_container)
		label.update()
		yield(get_tree(), "idle_frame")
		label.rect_min_size.y = label.rect_size.y
		content_container.name = part
		content_container.rect_min_size = label.rect_min_size
		ypositions[part] = label.rect_position.y
	$ContentContainer/VBoxContainer.rect_min_size = $ContentContainer/VBoxContainer.rect_size

func _on_Content_meta_clicked(meta):
	meta = String(meta)
	print("Meta clicked: ", meta)
	if meta.begins_with("http"):
# warning-ignore:return_value_discarded
		OS.shell_open(meta)
	elif meta.begins_with("wiki://"):
		var new_page = meta.right(7)
		get_parent().change_to(new_page)
