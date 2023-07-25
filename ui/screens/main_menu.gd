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
	var scene := "res://levels/level_%s.tscn" % str(randi() % ElevatorTransition.LEVEL_VARIATIONS)
	change_scene(scene)
