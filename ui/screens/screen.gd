class_name Screen
extends Control


func _ready() -> void:
	var fade := Fade.new()
	add_child(fade)
	fade.fade(Fade.FADE_OUT, 1.0)


func change_scene(scene: String) -> void:
	var fade := Fade.new()
	add_child(fade)
	fade.fade(Fade.FADE_IN, 1.0)
	yield(fade, "finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene(scene)
