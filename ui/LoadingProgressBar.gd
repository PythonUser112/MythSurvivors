extends ProgressBar

export (float) var color_change = 1.0

var state = 0
var style = StyleBoxFlat.new()
var current = Color(1, 0, 0, 0.75)

func _ready():
	style.bg_color = current
	style.border_blend = true
	style.border_color = Color.black
	style.border_width_bottom = 8
	style.border_width_top = 8
	style.border_width_left = 8
	style.border_width_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_top_right = 8
	style.corner_detail = 4
	set("custom_styles/fg", style)

func _process(delta):
	if state == 0:
		current.g += delta * color_change
		if current.g >= 1.0:
			current.r -= current.g - 1.0
			current.g = 1.0
			state += 1
	elif state == 1:
		current.r -= delta * color_change
		if current.r <= 0.0:
			current.b -= current.r
			current.r = 0.0
			state += 1
	elif state == 2:
		current.b += delta * color_change
		if current.b >= 1.0:
			current.g -= current.b - 1.0
			current.b = 1.0
			state += 1
	elif state == 3:
		current.g -= delta * color_change
		if current.g <= 0.0:
			current.r -= current.g
			current.g = 0.0
			state += 1
	elif state == 4:
		current.r += delta * color_change
		if current.r >= 1.0:
			current.b -= current.r - 1.0
			current.r = 1.0
			state += 1
	elif state == 5:
		current.b -= delta * color_change
		if current.b <= 0.0:
			current.g -= current.b
			current.b = 0.0
			state += 1
	style.bg_color = current
