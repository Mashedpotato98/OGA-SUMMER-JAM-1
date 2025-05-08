class_name Fade extends CanvasLayer


#region Members
enum FadeMode {FADE_IN, FADE_OUT}

signal finished
#endregion


#region Functions
func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 2


func fade(mode: FadeMode, duration: float) -> void:
	get_tree().paused = bool(not mode)
	var rect := ColorRect.new()
	rect.color = Color.BLACK
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(rect)
	show()
	rect.color.a = mode
	var tween := create_tween()
	tween.tween_property(rect, ^"color:a", float(not bool(mode)), duration)
	await tween.finished

	finished.emit()
	queue_free()
#endregion
