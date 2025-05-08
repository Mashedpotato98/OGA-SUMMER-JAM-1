class_name LoseScreen extends Screen


#region Functions
func _on_HomeButton_pressed() -> void:
	change_scene_to_file("res://ui/screens/main_menu.tscn")


func _on_QuitButton_pressed() -> void:
	get_tree().quit()
#endregion
