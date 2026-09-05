extends Control

var loaders: Array = []
var finished: Dictionary = {}
var finished_no = 0
var tasks = 0
var time_max: int = 15
var f = File.new()

func _ready():
	if Globals.config.get("developer", "0") == "1":
		if get_tree().change_scene("res://ui/Main.tscn") == OK:
			return
	Modulate.fade_in()
	yield(Modulate, "finished")
	var intro_handler = load_asset("ui/Intro.tscn")
	var main_handler = load_asset("ui/Main.tscn")
	var splash
	if f.file_exists("res://splash.png") or f.file_exists("user://splash.png"):
		splash = yield(load_asset("splash.png"), "completed")
	var intro_scene = yield(intro_handler, "completed").instance()
	var main_scene = yield(main_handler, "completed")
	Modulate.fade_out()
	yield(Modulate, "finished")
	$LoadingScene.queue_free()
	add_child(intro_scene)
	intro_scene.splash = splash
	Modulate.show_everything()
	yield(intro_scene, "finished")
	Modulate.fade_out()
	yield(Modulate, "finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(main_scene)

func load_asset(asset: String):
	var load_path: String
	if asset.begins_with("/") or asset.begins_with("C:\\")\
	or asset.begins_with("res://") or asset.begins_with("user://"):
		load_path = asset
	elif f.file_exists("user://" + asset):
		load_path = "user://" + asset
	elif f.file_exists("res://" + asset):
		load_path = "res://" + asset
	else:
		load_path = ""
	if not f.file_exists(load_path):
		push_error("Couldn't find asset '%s'"%(asset))
		breakpoint
		return
	loaders.append([ResourceLoader.load_interactive(load_path), load_path])
	tasks += 1
	while not load_path in finished:
		yield(get_tree(), "idle_frame")
	finished_no += 1
	$LoadingScene/LoadingProgressBar.value = 100.0 * finished_no / tasks
	return finished[load_path]

func _process(_delta):
	if loaders == []:
		set_process(false)
		return
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max:
		if not loaders:
			return
		var err = loaders[0][0].poll()
		if err == ERR_FILE_EOF:
			var resource = loaders[0][0].get_resource()
			finished[loaders[0][1]] = resource
			loaders.remove(0)
			return
		elif err == OK:
			var progress = (100.0 * loaders[0][0].get_stage() / loaders[0][0].get_stage_count() + finished_no) / tasks
			$LoadingScene/LoadingProgressBar.value = progress
		else:
			loaders = []
			return
