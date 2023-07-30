class_name MainMenu
extends Screen


onready var title: Label = $Title
onready var play_button: Button = $Menu/StartButtons/PlayButton


func _ready() -> void:
	._ready()
	title.text = ProjectSettings.get_setting("application/config/name")
	play_button.grab_focus()


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_PlayButton_pressed() -> void:
	change_scene(ElevatorTransition.get_level())


func _on_CreditsButton_pressed() -> void:
	change_scene("res://ui/screens/credits.tscn")


func _on_Tutorial_pressed() -> void:
	change_scene("res://levels/tutorial_2.tscn")


func _on_SettingsButton_pressed() -> void:
	change_scene("res://ui/screens/settings_menu.tscn")
