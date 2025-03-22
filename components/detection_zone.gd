class_name DetectionZone extends Area2D


#region Members
#region Signals
signal saw(what: Node)
signal lost(what: Node)
#endregion

var collisions := []

@onready var ray_cast: RayCast2D = $RayCast3D
#endregion


#region Functions
#region Overrides
func _ready() -> void:
	ray_cast.add_exception(owner)


func _process(_delta: float) -> void:
	for collider: CollisionObject2D in get_colliders():
		if collider == owner:
			continue

		ray_cast.target_position = to_local(collider.global_position)
		ray_cast.force_raycast_update()

		var hit_collider: bool = ray_cast.is_colliding() and ray_cast.get_collider() == collider
		if hit_collider:
			if not collisions.has(collider):
				see(collider)
		elif collisions.has(collider):
			lose(collider)
#endregion



#region Regular
func see(collider: Node) -> void:
	collisions.append(collider)
	saw.emit(collider)


func lose(collider: Node) -> void:
	collisions.erase(collider)
	lost.emit(collider)


func get_colliders() -> Array:
	var colliders := get_overlapping_bodies()
	colliders.append_array(get_overlapping_areas())
	return colliders
#endregion


#region Events
func _on_collider_exited(collider: Node) -> void:
	if get_colliders().size() <= 0:
		ray_cast.enabled = false
	if collisions.has(collider):
		lose(collider)


func _on_collider_entered(_collider: Node) -> void:
	ray_cast.enabled = true
#endregion
#endregion
