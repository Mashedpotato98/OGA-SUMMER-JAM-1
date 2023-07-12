class_name DetectionZone
extends Area2D


signal saw(what)
signal lost(what)

var collisions := []

onready var ray_cast: RayCast2D = $RayCast


func _ready() -> void:
	ray_cast.add_exception(owner)


func _process(_delta: float) -> void:
	for collider in get_colliders():
		if collider == owner:
			continue

		ray_cast.cast_to = to_local(collider.global_position)
		ray_cast.force_raycast_update()

		var hit_collider: bool = ray_cast.is_colliding() and ray_cast.get_collider() == collider
		if hit_collider:
			if not collisions.has(collider):
				see(collider)
		elif collisions.has(collider):
			lose(collider)



func see(collider: Node) -> void:
	collisions.append(collider)
	emit_signal("saw", collider)


func lose(collider: Node) -> void:
	collisions.erase(collider)
	emit_signal("lost", collider)


func get_colliders() -> Array:
	var colliders := get_overlapping_bodies()
	colliders.append_array(get_overlapping_areas())
	return colliders


func _on_collider_exited(collider: Node) -> void:
	if get_colliders().size() <= 0:
		ray_cast.enabled = false
	if collisions.has(collider):
		lose(collider)


func _on_collider_entered(_collider: Node) -> void:
	ray_cast.enabled = true
