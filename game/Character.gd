extends Area2D

export (String) var character
export (int) var speed = 16
var idle_anim_frame = 0
var idle_anim = 0
var old_direction = 2

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
	"left": Vector2(-1, 0),
	"right": Vector2(1, 0),
	"up": Vector2(0, -1),
	"down": Vector2(0, 1)
}

const diridx = {
	"up": 0,
	"right": 1,
	"down": 2,
	"left": 3
}

func move(dir):
	if moving or not dir in directions or raycasts[dir].is_colliding():
		return
	moving = true
	idle_anim_frame = 0
	$IdleTimer.stop()
	$FrameTimer.stop()
	if (diridx[dir] - old_direction) in [2, -2]:
		var between = (diridx[dir] + old_direction) / 2 + (randi() % 2) * 2
		var anim = diridx.keys()[between]
		$AnimatedSprite.animation = anim
		$AnimatedSprite.playing = false
		$AnimatedSprite.frame = 0
		$FrameTimer.start()
		yield($FrameTimer, "timeout")
	old_direction = diridx[dir]
	if not raycasts[dir].is_colliding():
		$Tween.interpolate_property(self, "position", null, position + directions[dir] * speed, 0.5)
		$Tween.start()
		$AnimatedSprite.play(dir)

func _on_Tween_tween_all_completed():
	moving = false
	if $AnimatedSprite.animation == "up":
		idle_anim_frame = 2
		idle_anim = randi() % 2
	elif $AnimatedSprite.animation != "down":
		idle_anim_frame = 1
		if $AnimatedSprite.animation == "left":
			idle_anim = 0
		else:
			idle_anim = 1
	else:
		idle_anim_frame = 0
	$AnimatedSprite.stop()
	$AnimatedSprite.frame = 0
	if idle_anim_frame:
		$IdleTimer.start()

func _ready():
	$AnimatedSprite.frames.add_frame("idle", Characters.get_character(character).get_picture("idle"))
	for dir in directions:
		for frame in range(4):
			$AnimatedSprite.frames.add_frame(dir, Characters.get_character(character).get_picture(dir + "/%s" % frame))
		raycasts[dir].collision_mask = collision_mask
	yield(get_tree(), "idle_frame")
	$AnimatedSprite.play("idle")

func _on_IdleTimer_timeout():
	$FrameTimer.start()

func _on_FrameTimer_timeout():
	if idle_anim_frame > 0:
		idle_anim_frame -= 1
		if idle_anim_frame > 0: # idle_anim_frame must be 1, so either turn left or right
			$AnimatedSprite.animation = ["left", "right"][idle_anim]
			$AnimatedSprite.playing = false
			$AnimatedSprite.frame = 0
			$FrameTimer.start()
		else:
			$AnimatedSprite.play("idle")
