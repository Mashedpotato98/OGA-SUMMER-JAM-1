extends Node


var file_path := "user://settings"
var data := {music_vol = 0.0, sfx_vol = 0.0, blood_mode = true}


func _ready() -> void:
	load_data()
	AudioServer.set_bus_volume_db(1, data.music_vol)
	AudioServer.set_bus_volume_db(2, data.sfx_vol)


func load_data() -> void:
	var file := File.new()
	if file.file_exists(file_path):
		var error := file.open(file_path, File.READ)
		if error == OK:
			data = file.get_var()
		else:
			OS.alert("Could not load settings. Error code: " + str(error))
	else:
		save_data()

	file.close()


func save_data() -> void:
	var file := File.new()
	var error := file.open(file_path, File.WRITE)
	if error == OK:
		file.store_var(data)
	else:
		OS.alert("Could not save settings. Error code: " + str(error))

	file.close()
