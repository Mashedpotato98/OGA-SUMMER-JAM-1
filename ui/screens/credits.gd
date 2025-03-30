class_name Credits extends Screen


#region Functions
func _on_BackButton_pressed() -> void:
	change_scene_to_file("res://ui/screens/main_menu.tscn")


func _on_Text_meta_clicked(meta) -> void:
	OS.shell_open(meta)
#endregion
#endregion
