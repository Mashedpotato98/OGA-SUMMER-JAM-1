class_name SoftCollider
extends Area2D


export var strength := 0.75


func get_safe_velocity(velocity: Vector2) -> Vector2:
	var length := velocity.length()
	for soft_collider in get_overlapping_areas():
		velocity += soft_collider.global_position.direction_to(global_position) * length * strength
	velocity = velocity.normalized() * length

	return velocity
