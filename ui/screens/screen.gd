class_name Screen extends Control


@export var focused_button: Control


#region Functions
func _ready() -> void:
	var fade := Fade.new()
	add_child(fade)
	fade.fade(Fade.FadeMode.FADE_OUT, 1.0)
	if focused_button != null:
		focused_button.grab_focus()


func change_scene_to_packed(scene: PackedScene) -> void:
	var fade := Fade.new()
	add_child(fade)
	fade.fade(Fade.FadeMode.FADE_IN, 1.0)
	await fade.finished
	get_tree().change_scene_to_packed(scene)


func change_scene_to_file(scene: String) -> void:
	change_scene_to_packed(load(scene))
#endregion
