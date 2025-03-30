# TODO: Map music and sfx volume sliders to curve.
class_name SettingsMenu extends Screen


#region Members
const VOLUME_CURVE := preload("res://music/volume_curve.tres")

#region Onready
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var blood_mode_toggle: CheckButton = %BloodModeToggle
#endregion
#endregion


#region Functions
func _ready() -> void:
	music_slider.value = inverse_lerp(Music.MIN_VOLUME, 0.0, Settings.data.music_vol)
	sfx_slider.value = inverse_lerp(Music.MIN_VOLUME, 0.0, Settings.data.sfx_vol)
	blood_mode_toggle.button_pressed = Settings.data.blood_mode
	super()


#region Events
func _on_SaveButton_pressed() -> void:
	Settings.data.music_vol = AudioServer.get_bus_volume_db(1)
	Settings.data.sfx_vol = AudioServer.get_bus_volume_db(2)
	Settings.data.blood_mode = blood_mode_toggle.button_pressed
	Settings.save_file()

	change_scene_to_file("res://ui/screens/main_menu.tscn")


func _on_CancelButton_pressed() -> void:
	AudioServer.set_bus_volume_db(1, Settings.data.music_vol)
	AudioServer.set_bus_volume_db(2, Settings.data.sfx_vol)
	change_scene_to_file("res://ui/screens/main_menu.tscn")


func _on_MusicSlider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, lerp(-80.0, 0.0, value))


func _on_SFXSlider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, lerp(-80.0, 0.0, value))
#endregion
#endregion
