extends Control

var current_test: Node

func _enter_tree():
	var d = Directory.new()
	if d.open("res://tests") != OK:
		push_error("Couldn't init tests!")
	d.list_dir_begin()
	var next = " "
	while next:
		next = d.get_next()
		if next.ends_with("Test.tscn"):
			var button = UIButton.new()
			button.text = next
			button.connect("button_down", self, "instantiate_scene", ["res://tests/" + next])
			$TestMenu.add_child(button)
	d.list_dir_end()

func _ready():
	Modulate.fade_in()
	yield(Modulate, "finished")
	$TestMenu.activate()

func instantiate_scene(scene_path: String):
	$TestMenu.hide()
	current_test = load(scene_path).instance()
	add_child(current_test)
	$TopLayer/CenterContainer/Button.text = "End test"

func _on_Button_pressed():
	if current_test == null:
		$TopLayer/CenterContainer/Button.disabled = true
		Modulate.fade_out()
		yield(Modulate, "finished")
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://developers/DeveloperMenu.tscn")
	current_test.queue_free()
	current_test = null
	$TopLayer/CenterContainer/Button.text = "Back to developer menu"
	$TestMenu.show()
	$TestMenu.activate()
