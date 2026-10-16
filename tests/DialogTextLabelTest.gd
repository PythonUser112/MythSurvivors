extends Control

func _ready():
	yield(get_tree().create_timer(0.5), "timeout") # Verhindert, dass manche Tasten tausendfach generiert werden
	$DialogTextLabel.show_text("Hello! Press <<select>> to continue!")
	yield($DialogTextLabel, "finished")
	$DialogTextLabel.show_text("You can also use this combination to skip drawing!")
	yield($DialogTextLabel, "finished")
	$DialogTextLabel.show_text("Go up(<<up>>) and down(<<down>>)\n and left(<<left>>) and right(<<right>>)")
	yield($DialogTextLabel, "finished")
