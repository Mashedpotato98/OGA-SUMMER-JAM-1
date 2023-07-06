class_name Screen
extends Control


func _ready() -> void:
	var fade := Fade.new()
	add_child(fade)
	fade.fade(Fade.FADE_OUT, 1.0)
