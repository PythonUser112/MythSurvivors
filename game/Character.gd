extends Area2D

export (String) var character

var mana = 0
var hp = 0
var atk = 0
var def = 0
var moving = false

onready var raycasts = {
	"left": $RayLeft,
	"right": $RayRight,
	"up": $RayUp,
	"down": $RayDown
}

const directions = {
	"left": Vector2(-8, 0),
	"right": Vector2(8, 0),
	"up": Vector2(0, -8),
	"down": Vector2(0, 8)
}

func move(dir):
	if not dir in directions or moving:
		return
	if not raycasts[dir].is_colliding():
		$AnimatedSprite.play(dir)
		$Tween.interpolate_property(self, "position", null, position + directions[dir], 0.5)
		$Tween.start()

func _on_AnimatedSprite_animation_finished():
	moving = false
	$AnimatedSprite.play("idle")

func _ready():
	$AnimatedSprite.frames.add_frame("idle", Characters.get_character(character).get_picture("idle"))
	for dir in directions:
		for frame in range(4):
			$AnimatedSprite.frames.add_frame(dir, Characters.get_character(character).get_picture(dir + "/%s" % frame))
	yield(get_tree(), "idle_frame")
	$AnimatedSprite.play("idle")
