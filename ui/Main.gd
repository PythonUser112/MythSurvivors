extends Control

func _ready():
	if OS.has_feature("developer"):
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://developers/DeveloperMenu.tscn")
