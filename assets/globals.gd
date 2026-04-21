extends Node

export (bool) var developer_mode = false
export (String) var lang
var config = {}
const config_path = "user://config.txt"

func _ready():
	var f = File.new()
	if not f.file_exists(config_path):
		f.open(config_path, File.WRITE_READ)
	else:
		f.open(config_path, File.READ)
	var content = f.get_as_text().split("\n")
	f.close()
	for line in content:
		if ": " in line and line.begins_with("- "):
			line = line.right(2).split(": ")
			config[line[0]] = line[1]
	print_debug(config)
	developer_mode = config.get("developer", null) != null or OS.has_feature("developer")
	Locale.lang = config.get("lang")
	Locale.init()

func update_config(new_cfg: Dictionary):
	for key in new_cfg:
		config[key] = new_cfg[key]
	var f = File.new()
	f.open(config_path, File.WRITE)
	for key in config:
		f.store_string("- " + str(key) + ": " + str(config[key]) + "\n")
	f.close()
