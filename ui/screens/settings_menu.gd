class_name SettingsMenu
extends Screen


onready var menu: VBoxContainer = $Menu
onready var music_slider: HSlider = menu.get_node("Music/MusicSlider")
onready var sfx_slider: HSlider = menu.get_node("SFX/SFXSlider")
onready var blood_mode_toggle: CheckButton = menu.get_node("BloodMode/BloodModeToggle")


func _ready() -> void:
	music_slider.value = inverse_lerp(-80.0, 0.0, Settings.data.music_vol)
	sfx_slider.value = inverse_lerp(-80.0, 0.0, Settings.data.sfx_vol)
	blood_mode_toggle.pressed = Settings.data.blood_mode
	music_slider.grab_focus()


func _on_SaveButton_pressed() -> void:
	Settings.data.music_vol = AudioServer.get_bus_volume_db(1)
	Settings.data.sfx_vol = AudioServer.get_bus_volume_db(2)
	Settings.data.blood_mode = blood_mode_toggle.pressed
	Settings.save_data()

	change_scene("res://ui/screens/main_menu.tscn")


func _on_CancelButton_pressed() -> void:
	AudioServer.set_bus_volume_db(1, Settings.data.music_vol)
	AudioServer.set_bus_volume_db(2, Settings.data.sfx_vol)
	change_scene("res://ui/screens/main_menu.tscn")


func _on_MusicSlider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, lerp(-80.0, 0.0, value))


func _on_SFXSlider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, lerp(-80.0, 0.0, value))
