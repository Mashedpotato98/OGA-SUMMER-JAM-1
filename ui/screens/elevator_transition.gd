class_name ElevatorTransition
extends Control


const LEVELS := 3
const LEVEL_VARIATIONS := 19 # Should be automated based on files

@onready var level_display: Sprite2D = $LevelDisplay


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

	var LEVEL: PackedScene = load(get_level())
	var level := LEVEL.instantiate()

	level.height = next_height
	get_node("/root").add_child(level)
	level.robber.hp = robber_hp

	get_tree().current_scene = level
	queue_free()


static func get_level() -> String:
	randomize()
	var result: String
	while result in ["", "res://levels/level_14.tscn", "res://levels/level_18.tscn"]:
		result = "res://levels/level_%s.tscn" % str(randi() % LEVEL_VARIATIONS + 1)
	return result
