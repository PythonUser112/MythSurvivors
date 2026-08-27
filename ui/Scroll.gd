tool

extends Control
class_name Scroll

export (String, MULTILINE) var text
export (int) var lift_height = 20
export (float) var lift_duration = 0.5
export (Color) var bg_color = Color("#bfaa69")

var time: float = 0
var oldtext: String = ""
var rich_text_label

func _ready():
	rich_text_label = RichTextLabel.new()
	rich_text_label.bbcode_enabled = true
	rich_text_label.install_effect(ScrollDecipher.new())
	var color_rect = ColorRect.new()
	color_rect.color = bg_color
	color_rect.rect_size = rect_size
	rich_text_label.rect_size = rect_size - Vector2(20, 20)
	rich_text_label.rect_position = Vector2(10, 10)
	rich_text_label.set("custom_fonts/normal_font", preload("res://assets/fonts/Italianno.tres"))
	rich_text_label.set("custom_constants/shadow_offset_y", 0)
	rich_text_label.set("custom_colors/font_color_shadow", Color.black)
	rich_text_label.set("custom_colors/default_color", Color.black)
	add_child(color_rect)
	add_child(rich_text_label)

func _process(delta):
	if not rich_text_label:
		rich_text_label = RichTextLabel.new()
		rich_text_label.bbcode_enabled = true
		rich_text_label.install_effect(ScrollDecipher.new())
		var color_rect = ColorRect.new()
		color_rect.color = bg_color
		color_rect.rect_size = rect_size
		rich_text_label.rect_size = rect_size - Vector2(20, 20)
		rich_text_label.rect_position = Vector2(10, 10)
		rich_text_label.set("custom_fonts/normal_font", preload("res://assets/fonts/Italianno.tres"))
		rich_text_label.set("custom_constants/shadow_offset_y", 0)
		rich_text_label.set("custom_colors/font_color_shadow", Color.black)
		rich_text_label.set("custom_colors/default_color", Color.black)
		add_child(color_rect)
		add_child(rich_text_label)
	if text != oldtext:
		oldtext = text
		rich_text_label.bbcode_text = "\n[center][scroll lift_height=%s lift_duration=%s deglibberish_duration=%s]%s[/scroll][/center]"%[lift_height, lift_duration, len(text) / 32.0 + 0.5, text]
		time = 0
	time += delta
	if time < lift_duration:
		rich_text_label.set("custom_constants/shadow_offset_y", round(lift_height * time / lift_duration))
