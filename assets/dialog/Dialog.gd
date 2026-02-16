extends Control

export (String) var dialog_file

signal dialog_finished

func show():
	$DialogActor1.rect_position = Vector2(0, -100)
	$DialogActor2.rect_position = Vector2(0, 600)
	.show()

func run():
	show()
	$DialogActor1.rect_position = Vector2(0, -100)
	$DialogActor2.rect_position = Vector2(0, 600)
	var label
	var f = File.new()
	f.open(dialog_file, File.READ)
	var lines: PoolStringArray = f.get_as_text().split("\n")
	var characters: Dictionary = {}
	var dialog_text: Array = []
	var is_characters = false
	var is_dialogue = false
	for line in lines:
		if not is_characters and line == "Characters:":
			is_characters = true
		elif is_characters:
			if line == "":
				is_characters = false
			else:
				var character_name = line.split(":")[0]
				var character_filename = line.split(":")[1].lstrip(" ")
				characters[character_name] = character_filename
		if not is_dialogue and line == "Dialogue:":
			is_dialogue = true
		elif is_dialogue:
			if line == "":
				is_dialogue = false
			else:
				var actor = line.split("#")[0]
				var align = line.split("#")[1].split(":")[0]
				var text = line.split(":")[1].lstrip(" ")
				dialog_text.append([actor, text, align])
	for element in dialog_text:
		var actor = element[0]
		var text = element[1]
		var align = element[2]
		var icon = IconManager.get_icon(actor)
		if icon:
			$DialogActor2/Actor2.texture = icon
		if align == "top":
			$DialogActor1/ActorLabel1.bbcode_text = "\n[center][jump_pulse]%s[/jump_pulse][/center]" % actor
			$Tween.interpolate_property($DialogActor1, "rect_position", null, Vector2(0, 0), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			$Tween.interpolate_property($DialogActor2, "rect_position", null, Vector2(0, 600), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		else:
			$DialogActor2/ActorLabel2.bbcode_text = "\n[center][jump_pulse]%s[/jump_pulse][/center]" % actor
			$Tween.interpolate_property($DialogActor1, "rect_position", null, Vector2(0, -100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			$Tween.interpolate_property($DialogActor2, "rect_position", null, Vector2(0, 500), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		$Tween.start()
		yield($Tween, "tween_all_completed")
		if label:
			label.text = ""
		label = get_node("DialogActor%s/DialogText"%(2 - int(align == "top")))
		label.show_text(text)
		yield(label, "finished")
		while not Input.is_action_pressed("select"):
			yield(get_tree(), "idle_frame")
	$Tween.interpolate_property($DialogActor1, "rect_position", null, Vector2(0, -100), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($DialogActor2, "rect_position", null, Vector2(0, 600), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	emit_signal("dialog_finished")
