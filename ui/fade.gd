class_name Fade
extends CanvasLayer


enum {FADE_IN, FADE_OUT}

signal finished


func _init() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	layer = 2


func fade(mode: int, duration: float) -> void:
	get_tree().paused = bool(not mode)
	var rect := ColorRect.new()
	rect.color = Color.black
	rect.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	add_child(rect)
	show()
	rect.color.a = mode
	var tween := create_tween()
# warning-ignore:return_value_discarded
	tween.tween_property(rect, "color:a", float(not bool(mode)), duration)
	yield(tween, "finished")

	emit_signal("finished")
	queue_free()
