extends Area2D

func _on_Apple_area_entered(area: Area2D):
	if area.is_in_group("Player"):
		area.lives += 1
