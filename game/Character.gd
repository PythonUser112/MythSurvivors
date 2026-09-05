extends Area2D

signal moving_finished

export (String) var character
export (bool) var npc = true
export (int) var speed = 16
export (int, "up", "right", "down", "left") var start_direction = 2
var old_direction

var mana = 0
var hp = 0
var atk = 0
var def = 0
var moving = false
var idle = false

onready var raycasts = {
	"up": $RayUp,
	"right": $RayRight,
	"down": $RayDown,
	"left": $RayLeft,
}

const directions = {
	"up": Vector2(0, -1),
	"right": Vector2(1, 0),
	"down": Vector2(0, 1),
	"left": Vector2(-1, 0)
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
	$IdleTimer.stop()
	$FrameTimer.stop()
	if idle:
		old_direction = $AnimatedSprite.frame
	if (diridx[dir] - old_direction) in [2, -2]:
		var between = ((diridx[dir] + old_direction) / 2 + (randi() % 2) * 2) % 4
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
	if moving:
		emit_signal("moving_finished")
	moving = false
	$AnimatedSprite.stop()
	$AnimatedSprite.frame = 0
	$IdleTimer.start()

func _ready():
	old_direction = start_direction
	for dir in directions:
		for frame in range(4):
			$AnimatedSprite.frames.add_frame(dir, Characters.get_character(character).get_picture(dir + "/%s" % frame))
		$AnimatedSprite.frames.add_frame("idle", Characters.get_character(character).get_picture(dir + "/0"))
		raycasts[dir].collision_mask = collision_mask
	yield(get_tree(), "idle_frame")
	$AnimatedSprite.animation = "idle"
	$AnimatedSprite.frame = old_direction
	$AnimatedSprite.playing = not npc

func _on_IdleTimer_timeout():
	idle = not npc
	$AnimatedSprite.animation = "idle"
	$AnimatedSprite.frame = old_direction
	$AnimatedSprite.playing = not npc
