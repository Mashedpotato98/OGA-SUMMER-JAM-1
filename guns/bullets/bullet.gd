class_name Bullet extends Area2D


#region Members
#region Export
@export var speed := 128.0
@export var dmg := 1
@export var HIT_EFFECT: PackedScene = null
@export var hit_on_out_of_range := false
#endregion

#region Variables
var attack_type := ""
var direction := Vector2()
var distance := 0.0
var distance_traveled := 0.0
#endregion
#endregion


#region Functions
#region Overrides
func _ready() -> void:
	set_as_top_level(true)


func _physics_process(delta: float) -> void:
	# This might go through hit boxes if slow frame rate / too fast speed.
	# In that case, use RayCast to detect wether it skipped anything.
	# perhaps only activate RayCast when it is moved over a certian amount within one frame.
	var velocity := direction * speed * delta
	translate(velocity)
	distance_traveled += velocity.length()

	if distance_traveled > distance:
		if hit_on_out_of_range:
			_hit()
		queue_free()


func _hit() -> Node2D:
	var hit_effect: Node2D = null
	if HIT_EFFECT != null:
		hit_effect = HIT_EFFECT.instantiate()
		hit_effect.global_position = global_position
		get_parent().add_child(hit_effect)

	queue_free()
	return hit_effect


func _post_translation() -> void:
	pass
#endregion


#region Events
func _on_Bullet_area_entered(area: Area2D) -> void:
	if not area is HitBox:
		return
	if area.owner.type == attack_type and area.owner.type != "all":
		return
	area.take_dmg(global_position, dmg)
	_hit()


#func _on_Bullet_body_entered(_body: Node) -> void:
# warning-ignore:return_value_discarded
#	_hit()


func _on_Bullet_body_shape_entered(_body_rid: RID, _body: Node,
		_body_shape_index: int, local_shape_index: int) -> void:
	var local_shape_owner := shape_find_owner(local_shape_index)
	var local_shape_node: CollisionShape2D = shape_owner_get_owner(local_shape_owner)
	if local_shape_node.name == &"WallCollider":
		_hit()
#endregion
#endregion
