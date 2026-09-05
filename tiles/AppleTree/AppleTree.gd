extends Area2D

export (bool) var loaded = false

func _ready():
	if loaded:
		$Sprite.texture = preload("res://tiles/AppleTree/AppleTree.png")

func _on_AppleTree_area_entered(area: Area2D):
	if area.is_in_group("PlayerWeapons") and loaded:
		$Sprite.texture = preload("res://tiles/AppleTree/Tree.png")
		var apple1 = preload("res://tiles/AppleTree/Apple.tscn").instance()
		get_parent().add_child(apple1)
		apple1.position = position + Vector2(16, 20)
		var apple2 = preload("res://tiles/AppleTree/Apple.tscn").instance()
		get_parent().add_child(apple2)
		apple2.position = position + Vector2(16, 20)
