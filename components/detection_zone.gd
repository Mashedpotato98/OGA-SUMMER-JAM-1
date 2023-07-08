class_name DetectionZone
extends Area2D


signal saw(what)
signal lost(what)

var collisions := []

onready var ray_cast: RayCast2D = $RayCast


func _ready() -> void:
	ray_cast.add_exception(owner)


func _process(_delta: float) -> void:
	var bodies := get_overlapping_bodies()
	for body in bodies:
		if body == owner:
			continue

		ray_cast.cast_to = to_local(body.global_position)
		ray_cast.force_raycast_update()

		var hit_body: bool = ray_cast.is_colliding() and ray_cast.get_collider() == body
		if hit_body:
			if not collisions.has(body):
				see(body)
		elif collisions.has(body):
			lose(body)



func see(body: Node) -> void:
	collisions.append(body)
	emit_signal("saw", body)


func lose(body: Node) -> void:
	collisions.erase(body)
	emit_signal("lost", body)


func _on_DetectionZone_body_entered(_body: Node) -> void:
	ray_cast.enabled = true


func _on_DetectionZone_body_exited(body: Node) -> void:
	if get_overlapping_bodies().size() <= 0:
		ray_cast.enabled = false
	if collisions.has(body):
		lose(body)
