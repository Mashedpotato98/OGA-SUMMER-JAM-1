class_name AutoAimer
extends Node2D


export var turn_speed := 5.0

var target: Node2D = null
var shooting := false


func _physics_process(delta: float) -> void:
	if target == null:
		return

	var direction := global_position.direction_to(target.global_position)
	var target_transform := Transform2D(direction.angle(), transform.origin)
	transform = transform.interpolate_with(target_transform, turn_speed * delta)


func set_target(what: Node) -> void:
	target = what


func lose_target(_what := Node.new()) -> void:
	target = null
