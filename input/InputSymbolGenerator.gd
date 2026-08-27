extends Control

export (String, FILE) var filestorage = "usr://inputsymbols.txt"

enum {
	KEYBOARD
	JOYBUTTON
	JOYSTICK
}

const KEYBOARD_SPECIALS = {
	KEY_ALT: "ALT",
	KEY_BACKSPACE: "BACKSPACE",
	KEY_CONTROL: "CTRL",
	KEY_DELETE: "DEL",
	KEY_DOWN: "↓",
	KEY_ENTER: "ENTER",
	KEY_ESCAPE: "ESC",
	KEY_F1: "F1",
	KEY_F2: "F2",
	KEY_F3: "F3",
	KEY_F4: "F4",
	KEY_F5: "F5",
	KEY_F6: "F6",
	KEY_F7: "F7",
	KEY_F8: "F8",
	KEY_F9: "F9",
	KEY_F10: "F10",
	KEY_F11: "F11",
	KEY_F12: "F12",
	KEY_F13: "F13",
	KEY_F14: "F14",
	KEY_F15: "F15",
	KEY_F16: "F16",
	KEY_INSERT: "INST",
	KEY_LEFT: "←",
	KEY_RIGHT: "→",
	KEY_SHIFT: "SHIFT",
	KEY_SPACE: "SPACE",
	KEY_SUPER_L: "WINDOWS",
	KEY_SUPER_R: "WINDOWS",
	KEY_UP: "↑"
}

const JOYBUTTONS = {
	JOY_BUTTON_0: ["A", Color.green],
	JOY_BUTTON_1: ["B", Color.red],
	JOY_BUTTON_2: ["X", Color.cyan],
	JOY_BUTTON_3: ["Y", Color.orange],
	JOY_BUTTON_4: ["L1", Color.black],
	JOY_BUTTON_5: ["R1", Color.black],
	JOY_BUTTON_6: ["L2", Color.black],
	JOY_BUTTON_7: ["R2", Color.black],
	JOY_BUTTON_8: ["L3", Color.black],
	JOY_BUTTON_9: ["R3", Color.black],
	JOY_BUTTON_10: ["SELECT", Color.black],
	JOY_BUTTON_11: ["START", Color.black],
	JOY_BUTTON_12: ["↑DPAD", Color.black],
	JOY_BUTTON_13: ["DPAD↓", Color.black],
	JOY_BUTTON_14: ["←DPAD", Color.black],
	JOY_BUTTON_15: ["DPAD→", Color.black],
	JOY_BUTTON_16: ["HOME", Color.black]
}

const rot = [[0, -1], [1, 0], [0, 1], [-1, 0]]

var symbols = {}
const SYMBOL_TEMPLATE = "[img src=%s][/img]"
var storagefile_content: String

func _ready():
	var f = File.new()
	if f.open(filestorage, File.READ):
		if f.open(filestorage, File.WRITE):
			push_error("Couldn't open storage!")
			return
		else:
			print_debug("Storage file created!")
		f.close()
	else:
		storagefile_content = f.get_as_text()
		var content = storagefile_content.split("\n")
		f.close()
		for line in content:
			if line:
				line = line.split(": ")
				symbols[line[0]] = line[1]

func get_joybutton_name(key):
	return JOYBUTTONS[key][0]

func get_joybutton_color(key):
	return JOYBUTTONS[key][1]

func get_keyboard_key_name(key):
	if not key in KEYBOARD_SPECIALS:
		return char(key).to_upper()
	return KEYBOARD_SPECIALS[key]

func add_color_rect(x, y, w, h, color):
	var crect = ColorRect.new()
	crect.color = color
	crect.rect_size = Vector2(w, h)
	crect.rect_position = Vector2(x, y)
	$InputSymbolViewport/Control.add_child(crect)

func add_color_rects(x, y, w, h, xsize, color):
	add_color_rect(x, y, w, h, color)
	add_color_rect(xsize - x - w, y, w, h, color)

func add_pixel(x, y, color=Color.black):
	add_color_rect(x, y, 1, 1, color)

func get_type_name(type):
	return {KEYBOARD: "KEYBOARD", JOYBUTTON: "JOYBUTTON", JOYSTICK: "JOYSTICK"}[type]

func wait():
	$InputSymbolViewport/Control.update()
	while not Input.is_action_just_pressed("select"):
		yield(VisualServer, "frame_post_draw")
	yield(VisualServer, "frame_post_draw")

func get_key_symbol(type, key):
	if get_type_name(type) + str(key) in symbols:
		yield(get_tree(), "idle_frame")
		return SYMBOL_TEMPLATE % symbols[get_type_name(type) + str(key)]
	var imagepath: String
	var image: Image = Image.new()
	if type == KEYBOARD:
		var keyname = get_keyboard_key_name(key)
		var xsize = 7 + 6 * len(keyname)
		$InputSymbolViewport.size = Vector2(xsize, 18)
		yield(get_tree(), "idle_frame")
		add_color_rects(0, 2, 1, 8, xsize, Color.black)
		add_color_rects(1, 1, 1, 2, xsize, Color.black)
		add_color_rects(2, 0, 1, 2, xsize, Color.black)
		add_color_rects(1, 9, 1, 2, xsize, Color.black)
		add_color_rects(2, 10, 1, 2, xsize, Color.black)
		add_color_rect(3, 0, xsize - 5, 1, Color.black)
		add_color_rect(3, 11, xsize - 5, 1, Color.black)
		add_color_rects(0, 10, 1, 6, xsize, Color.gray)
		add_color_rects(1, 11, 1, 6, xsize, Color.gray)
		for x in range(2, xsize - 2):
			add_color_rect(x, 12, 1, 6, Color.gray)
		add_color_rects(1, 3, 1, 6, xsize, Color.white)
		add_color_rects(2, 2, 1, 8, xsize, Color.white)
		add_color_rect(3, 1, xsize - 6, 10, Color.white)
		var positions = FontManager.render(FontManager.GLOBALFONT, keyname, Vector2(4, 2))
		for pos in positions:
			add_pixel(pos.x, pos.y)
		imagepath = "user://keysym_%s.png" % int(Time.get_unix_time_from_system() * 1000000)
	elif type == JOYBUTTON:
		var joybuttonname = get_joybutton_name(key)
		var joybuttoncolor = get_joybutton_color(key)
		var shadow = Color(joybuttoncolor.r / 2, joybuttoncolor.g / 2,joybuttoncolor.b / 2)
		if joybuttoncolor == Color.black:
			shadow = Color.gray
		var xsize = 7 + 6 * len(joybuttonname)
		$InputSymbolViewport.size = Vector2(xsize, 18)
		yield(get_tree(), "idle_frame")
		add_color_rects(0, 4, 1, 6, xsize, Color.black)
		add_color_rects(1, 2, 1, 3, xsize, Color.black)
		add_color_rects(1, 9, 1, 3, xsize, Color.black)
		add_color_rects(2, 1, 3, 1, xsize, Color.black)
		add_color_rects(2, 12, 3, 1, xsize, Color.black)
		add_pixel(2, 2)
		add_pixel(2, 11)
		add_pixel(xsize - 3, 2)
		add_pixel(xsize - 3, 11)
		add_color_rects(3, 1, 2, 1, xsize, Color.black)
		add_color_rects(3, 12, 2, 1, xsize, Color.black)
		add_color_rect(4, 0, xsize - 8, 1, Color.black)
		add_color_rect(4, 13, xsize - 8, 1, Color.black)
		add_color_rects(1, 5, 1, 4, xsize, Color.white)
		add_color_rects(2, 3, 1, 8, xsize, Color.white)
		add_color_rect(5, 1, xsize - 10, 1, Color.white)
		add_color_rect(5, 12, xsize - 10, 1, Color.white)
		add_color_rect(3, 2, xsize - 6, 1, Color.white)
		add_color_rect(3, 11, xsize - 6, 1, Color.white)
		add_color_rect(3, 3, xsize - 6, 8, Color.white)
		add_color_rects(0, 10, 1, 4, xsize, shadow)
		add_color_rects(1, 12, 1, 4, xsize, shadow)
		add_color_rects(2, 13, 1, 4, xsize, shadow)
		add_color_rects(3, 13, 1, 4, xsize, shadow)
		for x in range(4, xsize - 4):
			add_color_rect(x, 14, 1, 4, shadow)
		var positions = FontManager.render(FontManager.GLOBALFONT, joybuttonname, Vector2(4, 3))
		for pos in positions:
			add_pixel(pos.x, pos.y, joybuttoncolor)
		imagepath = "user://joybut_%s.png" % int(Time.get_unix_time_from_system() * 1000000)
	elif type == JOYSTICK:
		$InputSymbolViewport.size = Vector2(9, 18)
		add_color_rects(0, 2, 1, 3, 9, Color.black)
		add_color_rects(1, 1, 1, 2, 9, Color.black)
		add_color_rects(1, 4, 1, 2, 9, Color.black)
		add_color_rects(2, 0, 1, 2, 9, Color.black)
		add_color_rects(2, 5, 1, 2, 9, Color.black)
		add_color_rect(3, 0, 3, 1, Color.black)
		add_color_rect(3, 6, 3, 1, Color.black)
		add_color_rects(1, 3, 1, 1, 9, Color.gray)
		add_color_rects(2, 2, 1, 3, 9, Color.gray)
		add_color_rect(3, 1, 3, 5, Color.gray)
		add_pixel(4, 3, Color.black)
		add_pixel(0, 5, Color.gray)
		add_pixel(1, 6, Color.gray)
		add_color_rect(2, 7, 5, 1, Color.gray)
		add_pixel(7, 6, Color.gray)
		add_pixel(8, 5, Color.gray)
		add_color_rect(3, 8, 3, 8, Color.black)
		add_color_rects(0, 14, 1, 3, 9, Color.black)
		add_color_rects(1, 13, 1, 2, 9, Color.black)
		add_color_rects(1, 16, 1, 2, 9, Color.black)
		add_color_rects(2, 13, 1, 1, 9, Color.black)
		add_color_rects(2, 17, 1, 1, 9, Color.black)
		add_color_rects(1, 15, 1, 1, 9, Color.black)
		add_color_rects(2, 14, 1, 3, 9, Color.black)
		add_color_rect(3, 16, 3, 1, Color.black)
	while image.is_empty():
		$InputSymbolViewport/Control.update()
		yield(VisualServer, "frame_post_draw")
		image = $InputSymbolViewport.get_texture().get_data()
		if image.is_empty():
			push_error("No image data from viewport, retrying!")
			continue
	image.convert(Image.FORMAT_RGBA8)
# warning-ignore:return_value_discarded
	image.save_png(imagepath)
	storagefile_content += get_type_name(type) + str(key) + ": " + imagepath + "\n"
	var f = File.new()
	f.open(filestorage, File.WRITE)
	f.store_string(storagefile_content)
	f.close()
	for child in $InputSymbolViewport/Control.get_children():
		child.queue_free()
	yield(get_tree(), "idle_frame")
	return SYMBOL_TEMPLATE % imagepath
