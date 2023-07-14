class_name MainMenu
extends Screen


onready var title: Label = $Title
onready var play_button: Button = $Menu/PlayButton


func _ready() -> void:
	._ready()
	title.text = ProjectSettings.get_setting("application/config/name")
	play_button.grab_focus()


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_PlayButton_pressed() -> void:
	change_scene("res://levels/level_%s.tscn" % str(randi() % Level.LEVEL_VARIATIONS))
