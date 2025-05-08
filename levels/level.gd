class_name Level extends Node2D


#region Members
const ELEVATOR_TRANSITION := preload("res://ui/screens/elevator_transition.tscn")

#region Export
@export var track: AudioStream
@export var volume := 0.0
#endregion

var height := 0

#region Onready
@onready var robber: Robber = %Robber
@onready var elevator: Elevator = %Elevator
@onready var ui: UI = $UI
#endregion
#endregion


#region Functions
func _ready() -> void:
	elevator.needle.frame = height

	var fade := Fade.new()
	add_child(fade)
	fade.fade(Fade.FadeMode.FADE_OUT, 1.0)

	Music.change_track(track, volume)


func set_robber_hp(hp: int) -> void:
	robber.hp = hp


func level_up() -> void:
	if height < ElevatorTransition.LEVELS - 1:
		var fade := Fade.new()
		add_child(fade)
		fade.fade(Fade.FadeMode.FADE_IN, 1.0)
		await fade.finished

		var elevator_trans: ElevatorTransition = ELEVATOR_TRANSITION.instantiate()
		get_node("/root").add_child(elevator_trans)
		queue_free()
		elevator_trans.level_up(height, robber.hp)
	else:
		#get_tree().change_scene("res://ui/screens/win_screen.tscn")
		# Decided to go directly to shop instead.
		get_tree().change_scene_to_file("res://ui/screens/shop.tscn")
#endregion
