extends Control

var loaders: Array = []
var finished: Dictionary = {}
var finished_no = 0
var tasks = 0
var time_max: int = 15

func _ready():
	Modulate.fade_in()
	yield(Modulate, "finished")
	var main_scene = yield(load_asset("ui/Main.tscn"), "completed")
	Modulate.fade_out()
	yield(Modulate, "finished")
	get_tree().change_scene_to(main_scene)

func load_asset(asset: String):
	var load_path: String
	var f = File.new()
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
	loaders.append([ResourceLoader.load_interactive(load_path), load_path])
	tasks += 1
	while not load_path in finished:
		yield(get_tree(), "idle_frame")
	finished_no += 1
	$LoadingProgressBar.value = 100.0 * finished_no / tasks
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
			$LoadingProgressBar.value = progress
		else:
			loaders = []
			return
