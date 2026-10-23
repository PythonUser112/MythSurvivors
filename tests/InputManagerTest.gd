extends Control

func _ready():
	Modulate.show_everything()

func _process(_delta):
	InputManager.show()
	set_process(false)
