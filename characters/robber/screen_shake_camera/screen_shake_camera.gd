class_name ScreenShakeCamera extends Camera2D


func shake(distance: float, frequency: int, duration: float) -> void:
	var shake_duration := 1.0 / frequency
	for i in duration / shake_duration:
		var direction := Vector2(randf_range(-distance, distance), randf_range(-distance, distance))

		var tween := create_tween()
		tween.tween_property(self, ^"position", direction, shake_duration)
		await tween.finished
