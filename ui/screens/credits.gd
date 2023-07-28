class_name Credits
extends Screen


onready var back_button: Button = $Menu/BackButton


func _ready() -> void:
	back_button.grab_focus()


func _on_BackButton_pressed() -> void:
	change_scene("res://ui/screens/main_menu.tscn")


func _on_Text_meta_clicked(meta) -> void:
	OS.shell_open(meta)
