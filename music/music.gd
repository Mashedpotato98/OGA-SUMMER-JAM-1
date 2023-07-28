extends AudioStreamPlayer


export var fade_duration := 0.5

var track: AudioStream


func _ready() -> void:
	change_track(preload("res://music/tausdei_-_vice_police.mp3"), -10.0)


func change_track(to: AudioStream, volume := 0.0) -> void:
	if to == stream:
		return
	track = to

	var tween := create_tween()
# warning-ignore:return_value_discarded
	tween.tween_property(self, "volume_db", -80.0, fade_duration)
	yield(tween, "finished")

	stream = track
	play()
# warning-ignore:return_value_discarded
	create_tween().tween_property(self, "volume_db", volume, fade_duration)
