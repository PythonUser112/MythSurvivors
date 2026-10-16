extends Control

func _ready():
	Modulate.show_everything()
	yield(get_tree().create_timer(1), "timeout")
	InputManager.show()
