# I wonder if the load and save functions could be combined into one.
class_name SaveManager extends Node


#region Members
const DIRECTORY := "user://godot_4/"

var data := {}

@onready var filename := name.to_snake_case()
@onready var file_path := DIRECTORY + filename
#endregion


#region Functions
func load_file(password := "") -> void:
	if FileAccess.file_exists(file_path):
		var file := FileAccess.open(file_path, FileAccess.READ) if password == "" \
				else FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, password)
		var error := FileAccess.get_open_error()
		if error == OK:
			data = file.get_var()
		else:
			OS.alert("Could not load file {}.\nError: {}".format(filename, error_string(error)))
	else:
		save_file(password)


func save_file(password := "") -> void:
	if not DirAccess.dir_exists_absolute(DIRECTORY):
		@warning_ignore("confusable_local_declaration")
		var error := DirAccess.make_dir_recursive_absolute(DIRECTORY)
		if error != OK:
			OS.alert("Could not create save directory.\nError: " + error_string(error))
			return

	var file := FileAccess.open(file_path, FileAccess.WRITE) if password == "" \
			else FileAccess.open_encrypted_with_pass(file_path, FileAccess.WRITE, password)
	var error := FileAccess.get_open_error()
	if error == OK:
		file.store_var(data)
	else:
		OS.alert("Could not save file {}.\nError: {}".format(filename, error_string(error)))
#endregion
