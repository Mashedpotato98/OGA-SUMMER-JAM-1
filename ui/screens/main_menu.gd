class_name MainMenu extends Screen


#region Members
@onready var title: Label = $Title
@onready var play_button: Button = %PlayButton
#endregion


#region Functions
func _ready() -> void:
	super()
	title.text = ProjectSettings.get_setting("application/config/name")
	play_button.grab_focus()


#region Events
func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_PlayButton_pressed() -> void:
	change_scene_to_file(ElevatorTransition.get_level())


func _on_CreditsButton_pressed() -> void:
	change_scene_to_file("res://ui/screens/credits.tscn")


func _on_Tutorial_pressed() -> void:
	change_scene_to_file("res://levels/tutorial_2.tscn")


func _on_SettingsButton_pressed() -> void:
	change_scene_to_file("res://ui/screens/settings_menu.tscn")
#endregion
#endregion
