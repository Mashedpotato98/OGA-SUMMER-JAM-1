extends AudioStreamPlayer


export var fade_duration := 0.5

var track: AudioStream


func change_track(to: AudioStream, volume := 0) -> void:
	if to == stream:
		return
	track = to

	var tween := create_tween()
	tween.tween_property(self, "volume_db", -80.0, fade_duration)
	yield(tween, "finished")

	stream = track
	play()
	create_tween().tween_property(self, "volume_db", volume, fade_duration)
