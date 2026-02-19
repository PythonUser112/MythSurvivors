extends Control

export (String) var character
export (bool) var disabled = false

signal selected

func _ready():
	$Picture.texture = load("res://characters/%s/images/CharacterSelection.png" % character)
	var char_name = Characters.get_character(character)
	$Picture.material.set_shader_param("disabled", disabled)
	$Picture.material.set_shader_param("colors", 8.0)
	$Picture.material.set_shader_param("pixels", Vector2(200.0, 200.0))
	if disabled:
		$Name.bbcode_text = "\n[center][jump_pulse]?[/jump_pulse][/center]"
		$ShortDesc.bbcode_text = "\n[center][jump_pulse]?[/jump_pulse][/center]"
	$SelectButton.disabled = disabled

func _on_SelectButton_pressed():
	emit_signal("selected")
