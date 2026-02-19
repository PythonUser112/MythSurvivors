extends Control

export (String) var character_name
export (bool) var focused = false setget set_focus, get_focus
export (bool) var disabled = false

signal button_down
signal button_up

func set_focus(value):
	$SelectButton.focused = value

func get_focus():
	return $SelectButton.focused

func _ready():
	var character = Characters.get_character(character_name)
	$Picture.texture = character.get_picture("CharacterSelection")
	$Picture.material.set_shader_param("disabled", disabled)
	$Picture.material.set_shader_param("colors", 8.0)
	$Picture.material.set_shader_param("pixels", Vector2(200.0, 200.0))
	if disabled:
		$Name.bbcode_text = "\n[center][jump_pulse]?[/jump_pulse][/center]"
		$ShortDesc.bbcode_text = "\n[center][jump_pulse]?[/jump_pulse][/center]"
	$SelectButton.disabled = disabled

func _process(_delta):
	$SelectButton.disabled = disabled
	focused = $SelectButton.focused

func _on_SelectButton_button_up():
	emit_signal("button_up")

func _on_SelectButton_button_down():
	emit_signal("button_down")
