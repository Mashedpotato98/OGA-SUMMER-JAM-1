class_name AutoAimer
extends Node2D


export var turn_speed := 5.0

var robber: Robber = null
var shooting := false


func _physics_process(delta: float) -> void:
	if robber == null:
		return

	var direction := global_position.direction_to(robber.global_position)
	var target_transform := Transform2D(direction.angle(), transform.origin)
	transform = transform.interpolate_with(target_transform, turn_speed * delta)


# warning-ignore:shadowed_variable
func _on_DetectionZone_robber_entered(robber: Robber) -> void:
	self.robber = robber


func _on_DetectionZone_robber_exited() -> void:
	robber = null
