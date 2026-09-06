extends Control

enum {
	OPEN,
	QUIT,
	CLEAR,
	DESTROY
}

var saved = true
var mode
var url_type = 0
var lang = Locale.lang

func _ready():
	Modulate.fade_in()
	$EditorContainer/Editor/TextEdit.call_deferred("grab_focus")
	$EditorContainer/Editor/TextEdit.clear_colors()
	$EditorContainer/Editor/TextEdit.add_color_region("# ", "", Color.magenta)
	$EditorContainer/Editor/TextEdit.add_color_region("## ", "", Color.pink)
	$EditorContainer/Editor/TextEdit.add_color_region("[", ")", Color.aqua, true)
	$EditorContainer/Editor/TextEdit.add_color_region(" -", "- ", Color.gray, true)
	$EditorContainer/Editor/TextEdit.add_color_region(" _", "_ ", Color.aquamarine, true)
	$EditorContainer/Editor/TextEdit.add_color_region("\\-", " ", Color.turquoise, true)
	$EditorContainer/Editor/TextEdit.add_color_region("![", ")", Color.green, true)
	$EditorContainer/Editor/TextEdit.add_color_override("brace_mismatch_color", Color.red)
	$EditorContainer/Editor/TextEdit.add_color_override("function_color", Color.white)
	$EditorContainer/Editor/TextEdit.add_color_override("member_variable_color", Color.white)
	$EditorContainer/Editor/TextEdit.add_color_override("number_color", Color.white)
	$EditorContainer/Editor/TextEdit.add_color_override("symbol_color", Color.white)
	$NewURLDialog/GridContainer/TargetType.get_popup().connect("index_pressed", self, "change_index")
	get_tree().set_auto_accept_quit(false)

func _on_EditorContainer_tab_changed(tab):
	if tab == 0:
		$EditorContainer/Editor/TextEdit.grab_focus()
	else:
		$EditorContainer/Preview.redraw()

func _on_ClearButton_pressed():
	mode = CLEAR
	if not saved:
		$UnsavedChangesDialog.popup_centered()
		return
	$EditorContainer/Editor/TextEdit.text = ""
	$EditorContainer/Editor/TextEdit.grab_focus()

func _on_UnderlineButton_pressed():
	var cursorx = $EditorContainer/Editor/TextEdit.cursor_get_column()
	var cursory = $EditorContainer/Editor/TextEdit.cursor_get_line()
	var text_left = $EditorContainer/Editor/TextEdit.get_line(cursory).left(cursorx)
	var text_right = $EditorContainer/Editor/TextEdit.get_line(cursory).right(cursorx)
	var text = text_left + " __ " + text_right
	$EditorContainer/Editor/TextEdit.set_line(cursory, text)
	$EditorContainer/Editor/TextEdit.cursor_set_column(cursorx + 2)
	$EditorContainer/Editor/TextEdit.grab_focus()

func _on_CrossButton_pressed():
	var cursorx = $EditorContainer/Editor/TextEdit.cursor_get_column()
	var cursory = $EditorContainer/Editor/TextEdit.cursor_get_line()
	var text_left = $EditorContainer/Editor/TextEdit.get_line(cursory).left(cursorx)
	var text_right = $EditorContainer/Editor/TextEdit.get_line(cursory).right(cursorx)
	var text = text_left + " -- " + text_right
	$EditorContainer/Editor/TextEdit.set_line(cursory, text)
	$EditorContainer/Editor/TextEdit.cursor_set_column(cursorx + 2)
	$EditorContainer/Editor/TextEdit.grab_focus()

func _on_NewURLDialog_confirmed():
	var cursorx = $EditorContainer/Editor/TextEdit.cursor_get_column()
	var cursory = $EditorContainer/Editor/TextEdit.cursor_get_line()
	var text_left = $EditorContainer/Editor/TextEdit.get_line(cursory).left(cursorx)
	var text_right = $EditorContainer/Editor/TextEdit.get_line(cursory).right(cursorx)
	var target: String = $NewURLDialog/GridContainer/Target.text
	if url_type > 0:
		target = target.percent_encode()
	target = ["wiki://", "https://%s.wikipedia.org/wiki/" % lang, "https://"][url_type] + target
	if $NewURLDialog/GridContainer/TargetSection.editable and $NewURLDialog/GridContainer/TargetSection.text:
		target += "#" + $NewURLDialog/GridContainer/TargetSection.text
	var interior = "[%s](%s)"%[$NewURLDialog/GridContainer/Content.text, target]
	var text = text_left + interior + text_right
	$EditorContainer/Editor/TextEdit.set_line(cursory, text)
	$EditorContainer/Editor/TextEdit.cursor_set_column(cursorx + interior.length())

func _on_URLButton_pressed():
	$NewURLDialog/GridContainer/TargetSection.text = ""
	$NewURLDialog/GridContainer/Content.text = ""
	$NewURLDialog/GridContainer/Target.text = ""
	$NewURLDialog/GridContainer/TargetType.selected = 0
	$NewURLDialog.popup_centered()

func _on_NewURLDialog_popup_hide():
	$EditorContainer/Editor/TextEdit.grab_focus()

func _on_BackButton_pressed():
	mode = QUIT
	if not saved:
		$UnsavedChangesDialog.popup_centered()
		return
	Modulate.fade_out()
	yield(Modulate, "finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://developers/DeveloperMenu.tscn")

func _on_SaveDialog_file_selected(path):
	saved = true
	var f = File.new()
	f.open(path, File.WRITE)
	f.store_string($EditorContainer/Editor/TextEdit.text)
	f.close()
	$SaveFinishedDialog.popup_centered()

func _on_OpenDialog_file_selected(path):
	var f = File.new()
	f.open(path, File.READ)
	$EditorContainer/Editor/TextEdit.text = f.get_as_text()
	f.close()
	$EditorContainer/Editor/TextEdit.grab_focus()

func _on_SaveButton_pressed():
	$SaveDialog.popup_centered()

func _on_OpenButton_pressed():
	if saved:
		$OpenDialog.popup_centered()
	else:
		mode = OPEN
		$UnsavedChangesDialog.popup_centered()

func _on_HeadingButton_pressed():
	$EditorContainer/Editor/TextEdit.cursor_set_column(0)
	$EditorContainer/Editor/TextEdit.insert_text_at_cursor("# \n")
	$EditorContainer/Editor/TextEdit.cursor_set_line($EditorContainer/Editor/TextEdit.cursor_get_line() - 1)
	$EditorContainer/Editor/TextEdit.cursor_set_column(2)
	$EditorContainer/Editor/TextEdit.grab_focus()

func _on_Heading2Button_pressed():
	$EditorContainer/Editor/TextEdit.cursor_set_column(0)
	$EditorContainer/Editor/TextEdit.insert_text_at_cursor("## \n")
	$EditorContainer/Editor/TextEdit.cursor_set_line($EditorContainer/Editor/TextEdit.cursor_get_line() - 1)
	$EditorContainer/Editor/TextEdit.cursor_set_column(3)
	$EditorContainer/Editor/TextEdit.grab_focus()

func _on_ImageButton_pressed():
	$ImageDialog.popup_centered()

func _on_SaveFinishedDialog_popup_hide():
	$EditorContainer/Editor/TextEdit.grab_focus()

func _on_UnsavedChangesDialog_confirmed():
	if mode == OPEN:
		$OpenDialog.popup_centered()
	elif mode == CLEAR:
		$EditorContainer/Editor/TextEdit.text = ""
	elif mode == QUIT:
		get_tree().set_auto_accept_quit(true)
		Modulate.fade_out()
		yield(Modulate, "finished")
	# warning-ignore:return_value_discarded
		get_tree().change_scene("res://developers/DeveloperMenu.tscn")
	elif mode == DESTROY:
		get_tree().quit()

func _on_UnsavedChangesDialog_popup_hide():
	$EditorContainer/Editor/TextEdit.grab_focus()

func change_index(index):
	url_type = index
	$NewURLDialog/GridContainer/TargetLanguage.disabled = index != 1
	$NewURLDialog/GridContainer/TargetSection.editable = index != 2

func change_target_language(index):
	lang = $NewURLDialog/GridContainer/TargetLanguage.get_popup().get_item_text(index)

func _process(_delta):
	if Input.is_action_pressed("open_file"):
		if saved:
			$OpenDialog.popup_centered()
		else:
			mode = OPEN
			$UnsavedChangesDialog.popup_centered()
	elif Input.is_action_pressed("save_file"):
		$SaveDialog.popup_centered()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if saved:
			get_tree().quit()
		else:
			mode = DESTROY
			$UnsavedChangesDialog.popup_centered()

func _on_ImageDialog_file_selected(path):
	$EditorContainer/Editor/TextEdit.cursor_set_column(0)
	$EditorContainer/Editor/TextEdit.insert_text_at_cursor("![Image heading](%s)\n"%(path))
	$EditorContainer/Editor/TextEdit.cursor_set_line($EditorContainer/Editor/TextEdit.cursor_get_line() - 1)
	$EditorContainer/Editor/TextEdit.cursor_set_column(15)

func _on_ImageDialog_popup_hide():
	$EditorContainer/Editor/TextEdit.grab_focus()

func _on_TextEdit_text_changed():
	saved = false
