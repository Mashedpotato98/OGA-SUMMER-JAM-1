class_name DetectionZone
extends Area2D


signal robber_entered(robber)
signal robber_exited

var robber_detected := false

onready var ray_cast: RayCast2D = $RayCast


func _process(_delta: float) -> void:
	var bodies := get_overlapping_bodies()
	if bodies.size() > 0:
		var robber: Robber = bodies[0]# Will need to do some stuff if multiplayer
		ray_cast.cast_to = to_local(robber.global_position)
		if ray_cast.is_colliding() and ray_cast.get_collider() == robber:
			if not robber_detected:
				robber_detected = true
				emit_signal("robber_entered", robber)
		elif robber_detected:
			exit_robber()
	elif robber_detected:
		exit_robber()# Repeatative

func exit_robber() -> void:
	robber_detected = false
	emit_signal("robber_exited")


func _on_DetectionZone_body_entered(_body: Node) -> void:
	ray_cast.enabled = true


func _on_DetectionZone_body_exited(_body: Node) -> void:
	ray_cast.enabled = false
