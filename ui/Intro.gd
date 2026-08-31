extends Control

signal finished

var current = 1
var first_anim = false
var splash

func _ready():
	get_child(get_child_count() - 1).get_node("TextureRect").texture = splash
	$Tween.interpolate_property($Page1, "rect_position", null, Vector2(0, 280), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Tween_tween_all_completed():
	$Timer.start(3 + len(get_node("Page%s/RichTextLabel" % current).text) / 20.0)

func _on_Timer_timeout():
	$Tween.interpolate_property(get_node("Page%s" % current), "rect_position", null, Vector2(0, 600), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	current += 1
	if has_node("Page%s/TextureRect" % current):
		get_node("Page%s/TextureRect" % current).modulate = Color(1, 1, 1, 0)
		$Tween.interpolate_property(get_node("Page%s/TextureRect" % current), "modulate", null, Color.white, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 2)
	if has_node("Page%s" % current):
		first_anim = true
		$Tween.interpolate_property(get_node("Page%s" % current), "rect_position", null, Vector2(0, 280), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 1)
		$Tween.start()
	else:
		emit_signal("finished")

func _on_Tween_tween_completed(object, key):
	if first_anim:
		get_node("Page%s/RichTextLabel" % current).bbcode_text += " "
		first_anim = false
