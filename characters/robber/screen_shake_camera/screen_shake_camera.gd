class_name ScreenShakeCamera
extends Camera2D


func shake(distance: float, frequency: int, duration: float) -> void:
	var shake_duration := 1.0 / frequency
	for i in duration / shake_duration:
		var direction := Vector2(rand_range(-distance, distance), rand_range(-distance, distance))

		var tween := create_tween()
# warning-ignore:return_value_discarded
		tween.tween_property(self, "position", direction, shake_duration)
		yield(tween, "finished")
