class_name ElevatorTransition extends Control


#region Members
const LEVELS := 3

@onready var level_display: Sprite2D = $LevelDisplay
#endregion


func level_up(from_height: int, robber_hp: int) -> void:
	var next_height := from_height + 1
	level_display.frame = from_height

	var fade := Fade.new()
	add_child(fade)
	fade.fade(Fade.FadeMode.FADE_OUT, 1.0)
	await fade.finished

	level_display.frame = next_height
	await get_tree().create_timer(1.0).timeout

	var fade_in := Fade.new()
	add_child(fade_in)
	fade_in.fade(Fade.FadeMode.FADE_IN, 1.0)
	await fade_in.finished

	var level: Level = Settings.get_level().instantiate()

	level.height = next_height
	get_node(^"/root").add_child(level)
	level.set_robber_hp(robber_hp)

	get_tree().current_scene = level
	queue_free()
