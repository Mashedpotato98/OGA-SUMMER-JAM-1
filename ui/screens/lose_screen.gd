class_name LoseScreen extends Screen


@onready var home_button: Button = %HomeButton


#region Functions
func _ready() -> void:
	super()
	home_button.grab_focus()


#region Events
func _on_HomeButton_pressed() -> void:
	change_scene_to_file("res://ui/screens/main_menu.tscn")


func _on_QuitButton_pressed() -> void:
	get_tree().quit()
#endregion
#endregion
