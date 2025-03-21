extends Node


var path := "user://godot_4/"
var file := "settings"
var file_path := path + file
var data := {music_vol = 0.0, sfx_vol = 0.0, blood_mode = true}


func _ready() -> void:
	load_data()
	AudioServer.set_bus_volume_db(1, data.music_vol)
	AudioServer.set_bus_volume_db(2, data.sfx_vol)


func load_data() -> void:
	if FileAccess.file_exists(file_path):
		var file := FileAccess.open(file_path, FileAccess.READ)
		var error := FileAccess.get_open_error()
		if error == OK:
			data = file.get_var()
		else:
			OS.alert("Could not load settings.\nError: " + error_string(error))
	else:
		save_data()


func save_data() -> void:
	if not DirAccess.dir_exists_absolute(path):
		@warning_ignore("confusable_local_declaration")
		var error := DirAccess.make_dir_recursive_absolute(path)
		if error != OK:
			OS.alert("Could not create save directory.\nError: " + error_string(error))
			return

	var file := FileAccess.open(file_path, FileAccess.WRITE)
	var error := FileAccess.get_open_error()
	if error == OK:
		file.store_var(data)
	else:
		OS.alert("Could not save settings.\nError: " + error_string(error))
