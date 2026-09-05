extends Control

const WIKIPATH = "res://truthpedia/wiki/"

var current_page: Control
var files = {}

func _ready():
	var wikidir = Directory.new()
	if wikidir.open(WIKIPATH) != OK:
		push_error("Truthpedia wiki doesn't exist!")
		return
	wikidir.list_dir_begin()
	var dir
	var f = File.new()
	while dir != "":
		dir = wikidir.get_next()
		if wikidir.current_is_dir() and not dir.begins_with("."):
			if f.file_exists(WIKIPATH + dir + "/names.txt"):
				f.open(WIKIPATH + dir + "/names.txt", File.READ)
				var content = f.get_as_text().split("\n")
				f.close()
				for line in content:
					if line.begins_with("- "):
						line = line.right(2).split(":")
						if line[0] == Locale.lang:
							files[dir] = line[1]
	current_page = preload("res://truthpedia/WikiPage.tscn").instance()
	current_page.wikipage = "main"
	add_child(current_page)
	Modulate.fade_in()

func change_to(page, heading):
	if page != current_page.get("wikipage"):
		Modulate.fade_out()
		yield(Modulate, "finished")
		current_page.queue_free()
		current_page = preload("res://truthpedia/WikiPage.tscn").instance()
		current_page.wikipage = page
		add_child(current_page)
		yield(get_tree(), "idle_frame")
		if current_page.fail:
			current_page = preload("res://truthpedia/WikiPage.tscn").instance()
			current_page.wikipage = "main"
			add_child(current_page)
			$ErrorDialog.popup_centered()
		Modulate.fade_in()
		yield(Modulate, "finished")
	current_page.scroll_to(heading)

func _on_BackButton_button_down():
	Modulate.fade_out()
	yield(Modulate, "finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ui/Main.tscn")

func _on_SearchButton_pressed():
	var found = []
	for page in files:
		if $InfoLayer/WikiTitle/Search/LineEdit.text.to_lower() in files[page].to_lower():
			found.append(page)
	if not found:
		$AcceptDialog.dialog_text = "Sorry, but there aren't any pages about \"" + $InfoLayer/WikiTitle/Search/LineEdit.text + "\" available. Why not try on Wikipedia?"
		$AcceptDialog.popup_centered()
	else:
		Modulate.fade_out()
		yield(Modulate, "finished")
		current_page.queue_free()
		current_page = VBoxContainer.new()
		current_page.rect_position = Vector2(100, 100)
		var label = RichTextLabel.new()
		label.bbcode_enabled = true
		label.custom_effects = [JumpPulse.new()]
		label.bbcode_text = "\n[center][font=res://assets/fonts/Jacquard_24/FontBig.tres][jump_pulse]Search results[/jump_pulse][/font][/center]"
		label.rect_min_size.y = 40
		label.scroll_active = false
		current_page.add_child(label)
		for page in found:
			var button = UIButton.new()
			button.text = files[page]
			button.rect_min_size = Vector2(500, 200)
			button.connect("button_down", self, "change_to", [page, ""])
			current_page.add_child(button)
		add_child(current_page)
		Modulate.fade_in()
