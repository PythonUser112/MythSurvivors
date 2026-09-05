extends Control

export (String) var wikipage
export (bool) var fail = false

const title = "\n[center][jump_pulse][font=res://assets/fonts/Jacquard_24/FontBig.tres]%s[/font][/jump_pulse][/center]"
const heading = "\n[u][center][jump_pulse][font=res://assets/fonts/Jacquard_24/FontMedium.tres]%s[/font][/jump_pulse][/center][/u]"

var ypositions = {}

func _ready():
	var wiki = get_parent().WIKIPATH + wikipage + "/" + Locale.lang + ".md"
	var f = File.new()
	if not f.file_exists(wiki):
		push_error("Wikipage %s does not exist!" % wikipage)
		fail = true
		return
	f.open(wiki, File.READ)
	var content = f.get_as_text().split("\n")
	f.close()
	$TitlePanel/PageTitle.bbcode_text = title % get_parent().files[wikipage]
	var image_part = false
	var bbcode_text = ""
	var part = ""
	var content_container
	for line in content:
		if line.begins_with("# "):
			if bbcode_text:
				content_container = HBoxContainer.new()
				var label = RichTextLabel.new()
				label.custom_effects = [JumpPulse.new()]
				label.fit_content_height = true
				label.bbcode_enabled = true
				label.scroll_active = false
				label.bbcode_text = bbcode_text
				label.rect_min_size.x = 762
				label.rect_size.x = 762
				label.connect("meta_clicked", self, "_on_Content_meta_clicked")
				content_container.add_child(label)
				$ContentContainer/VBoxContainer.add_child(content_container)
				label.update()
				yield(get_tree(), "idle_frame")
				label.rect_min_size.y = label.rect_size.y
				content_container.name = part
				content_container.rect_min_size = label.rect_min_size
				ypositions[part] = content_container.rect_position.y
			part = line.right(2)
			image_part = true
			bbcode_text = "\n" + heading % part
			$TableOfContents/Index.bbcode_text += "\n[url=%s]%s[/url]"%[line.right(2), line.right(2)]
			continue
		if line.begins_with("## "):
			if bbcode_text:
				content_container = HBoxContainer.new()
				var label = RichTextLabel.new()
				label.custom_effects = [JumpPulse.new()]
				label.fit_content_height = true
				label.bbcode_enabled = true
				label.scroll_active = false
				label.bbcode_text = bbcode_text
				label.rect_min_size.x = 762
				label.rect_size.x = 762
				label.connect("meta_clicked", self, "_on_Content_meta_clicked")
				content_container.add_child(label)
				$ContentContainer/VBoxContainer.add_child(content_container)
				label.update()
				yield(get_tree(), "idle_frame")
				label.rect_min_size.y = label.rect_size.y
				content_container.name = part
				content_container.rect_min_size = label.rect_min_size
				ypositions[part] = content_container.rect_position.y
			part = line.right(3)
			image_part = true
			bbcode_text = heading % part
			$TableOfContents/Index.bbcode_text += "\n  [url=%s]%s[/url]"%[line.right(2), line.right(2)]
			continue
		if image_part:
			if line.strip_edges() == "":
				continue
			if line.begins_with("!["):
				var _path = line.split("(")[1].split(" ")[0].replace("wiki://", get_parent().WIKIPATH)
				var alt_text = line.split("[")[1].split("]")[0]
				bbcode_text += "\n[img]%s[/img]\n%s"%[_path, alt_text]
				continue
			image_part = false
		if bbcode_text and not image_part:
			var line_parsed = ""
			var state = 0
			var tmp1
			var tmp2
			var crossed = false
			var last_was_space = false
			var escaped = false
			for character in line:
				if character == "\\":
					escaped = true
					continue
				if state == 0:
					if character == "[" and not escaped:
						state = 1
						line_parsed += "[color=aqua][url="
						tmp1 = ""
						tmp2 = ""
					elif character == "-" and not escaped:
						if crossed and not last_was_space:
							line_parsed += "[/s][/color]"
							crossed = false
						elif not crossed:
							state = 3
					elif character == "_" and not escaped:
						if crossed and not last_was_space:
							line_parsed += "[/u]"
							crossed = false
						elif not crossed:
							state = 4
					else:
						line_parsed += character
				elif state == 1:
					if character == "]" and not escaped:
						state = 2
					else:
						tmp1 += character
				elif state == 2:
					if character == ")" and not escaped:
						line_parsed += tmp2
						line_parsed += "]"
						line_parsed += tmp1
						line_parsed += "[/url][/color]"
						state = 0
					elif character != "(" and not escaped:
						tmp2 += character
				elif state == 3:
					if character in [" ", "\n", "\t"]:
						line_parsed += "-"
					else:
						crossed = true
						line_parsed += "[color=grey][s]"
					line_parsed += character
					state = 0
				elif state == 4:
					if character in [" ", "\n", "\t"]:
						line_parsed += "_"
					else:
						crossed = true
						line_parsed += "[u]"
					line_parsed += character
					state = 0
				last_was_space = character in [" ", "\n", "\t"]
			bbcode_text += "\n[font=res://assets/fonts/Jacquard_24/FontSmall.tres]%s[/font]" % line_parsed
	if bbcode_text:
		content_container = VBoxContainer.new()
		var label = RichTextLabel.new()
		label.connect("meta_clicked", self, "_on_Content_meta_clicked")
		label.custom_effects = [JumpPulse.new()]
		label.rect_min_size.x = 762
		label.rect_size.x = 762
		label.fit_content_height = true
		label.bbcode_enabled = true
		label.scroll_active = false
		label.bbcode_text = bbcode_text
		content_container.add_child(label)
		$ContentContainer/VBoxContainer.add_child(content_container)
		label.update()
		yield(get_tree(), "idle_frame")
		label.rect_min_size.y = label.rect_size.y
		if part:
			content_container.name = part
		content_container.rect_min_size = label.rect_min_size
		ypositions[part] = content_container.rect_position.y
	$ContentContainer/VBoxContainer.rect_size.y = 0
	$ContentContainer/VBoxContainer.update()
	yield(get_tree(), "idle_frame")
	$ContentContainer/VBoxContainer.rect_min_size = $ContentContainer/VBoxContainer.rect_size

func _on_Content_meta_clicked(meta):
	meta = String(meta)
	if meta.begins_with("http"):
# warning-ignore:return_value_discarded
		OS.shell_open(meta)
	elif meta.begins_with("wiki://"):
		var new_page = meta.right(7)
		var heading = ""
		if "#" in meta:
			new_page = new_page.split("#")
			heading = new_page[1]
			new_page = new_page[0]
		get_parent().change_to(new_page, heading)

func _on_Index_meta_clicked(meta):
	scroll_to(meta)

func scroll_to(meta):
	if not meta:
		return
	meta = String(meta)
	var y_target = clamp(ypositions[meta] - 20, 0, $ContentContainer/VBoxContainer.rect_size.y)
	$Tween.interpolate_property($ContentContainer, "scroll_vertical", null, y_target, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
