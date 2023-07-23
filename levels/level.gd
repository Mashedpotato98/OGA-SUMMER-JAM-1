class_name Level
extends Node2D


const LEVELS := 5
const LEVEL_VARIATIONS := 2 # Should be automated based on files

# So that the map seed is separate from the game seed.
var rng := RandomNumberGenerator.new()
var height := 0

onready var y_sort: YSort = $YSort
onready var robber: Robber = y_sort.get_node("Robber")
onready var elevator: Elevator = y_sort.get_node("Elevator")
onready var ui: UI = $UI


func _ready() -> void:
	randomize()
	if height == 0:
		rng.seed = randi()
		print("first level")
	ui.set_seed(rng.seed)

	elevator.needle.frame = height

	var fade := Fade.new()
	add_child(fade)
	fade.fade(Fade.FADE_OUT, 1.0)


func level_up() -> void:
	if height < LEVELS - 1:
		var fade := Fade.new()
		add_child(fade)
		fade.fade(Fade.FADE_IN, 1.0)
		yield(fade, "finished")

		var LEVEL: PackedScene = load("res://levels/level_%s.tscn"
				% str(rng.randi() % LEVEL_VARIATIONS))
		var level := LEVEL.instance()
		level.height = height + 1
		level.rng.seed = rng.seed
		level.rng.state = rng.state
		print("new level seed: ", level.rng.seed)
		print("old seed: ", rng.seed)
		get_node("/root").add_child(level)
		level.robber.hp = robber.hp
		get_tree().current_scene = level
		queue_free()
	else:
# warning-ignore:return_value_discarded
#get_tree().change_scene("res://ui/screens/win_screen.tscn")
		get_tree().change_scene("res://ui/screens/shop.tscn") # Decided to go directly to shop instead.
