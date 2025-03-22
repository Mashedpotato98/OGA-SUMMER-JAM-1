class_name Screen
extends Control


func _ready() -> void:
	var fade := Fade.new()
	add_child(fade)
	fade.fade(Fade.FadeMode.FADE_OUT, 1.0)


func change_scene_to_file(scene: String) -> void:
	var fade := Fade.new()
	add_child(fade)
	fade.fade(Fade.FadeMode.FADE_IN, 1.0)
	await fade.finished
	get_tree().change_scene_to_file(scene)
