extends SaveManager

#region Members
@export var levels: Array[PackedScene] = []
#endregion


func _ready() -> void:
	data = {music_vol = 0.0, sfx_vol = 0.0, blood_mode = true}
	load_file()
	AudioServer.set_bus_volume_db(1, data.music_vol)
	AudioServer.set_bus_volume_db(2, data.sfx_vol)


func get_level() -> PackedScene:
	return preload('res://levels/playable_levels_old/level_19.tscn')#levels.pick_random()
