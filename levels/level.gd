class_name Level
extends Node2D


const ELEVATOR_TRANSITION := preload("res://ui/screens/elevator_transition.tscn")

var height := 0

onready var y_sort: YSort = $YSort
onready var robber: Robber = y_sort.get_node("Robber")
onready var elevator: Elevator = y_sort.get_node("Elevator")
onready var ui: UI = $UI


func _ready() -> void:
	randomize()

	elevator.needle.frame = height

	var fade := Fade.new()
	add_child(fade)
	fade.fade(Fade.FADE_OUT, 1.0)


func level_up() -> void:
	if height < ElevatorTransition.LEVELS - 1:
		var fade := Fade.new()
		add_child(fade)
		fade.fade(Fade.FADE_IN, 1.0)
		yield(fade, "finished")

		var elevator_trans: ElevatorTransition = ELEVATOR_TRANSITION.instance()
		get_node("/root").add_child(elevator_trans)
		queue_free()
		elevator_trans.level_up(height, robber.hp)
	else:
# warning-ignore:return_value_discarded
#		get_tree().change_scene("res://ui/screens/win_screen.tscn")
		get_tree().change_scene("res://ui/screens/shop.tscn") # Decided to go directly to shop instead.
