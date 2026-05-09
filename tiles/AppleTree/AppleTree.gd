extends Area2D

export (bool) var loaded = false

func _ready():
	if loaded:
		$Sprite.texture = preload("res://tiles/AppleTree/AppleTree.png")

func _on_AppleTree_area_entered(area: Area2D):
	if area.is_in_group("PlayerWeapons") and loaded:
		$Sprite.texture = preload("res://tiles/AppleTree/Tree.png")
		push_error("Npo apple-dropping method yet!")
