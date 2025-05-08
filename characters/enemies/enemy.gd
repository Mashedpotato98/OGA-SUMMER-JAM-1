class_name Enemy extends Character


#region Members
#region Variables
var player: Robber = null
var current_target: Node2D = null
var last_target_sighting := Vector2.INF
#endregion

#region Onready
@onready var soft_collider: SoftCollider = $SoftCollider
@onready var detection_zone: DetectionZone = $DetectionZone
#endregion
#endregion


#region Functions
#region Overrides
func _physics_process(delta: float) -> void:
	if not stunned:
		_move()
		smooth_vel = soft_collider.get_safe_velocity(smooth_vel)

	super(delta)


func _move() -> void:
	patrol()


func _chase(target: Node2D) -> void:
	smooth_vel = global_position.direction_to(target.global_position) * speed
#endregion


#region Regular
func search() -> void:
	if global_position.distance_to(last_target_sighting) > desired_distance:
		smooth_vel = global_position.direction_to(last_target_sighting) * speed
	else:
		choose_wander_point()
		last_target_sighting = Vector2.INF


func patrol() -> void:
	if not is_null(current_target):
		hand_pivot.set_target(current_target)
		_chase(current_target)
	else:
		hand_pivot.lose_target()
		if last_target_sighting != Vector2.INF:
			search()
		else:
			wander()


func lose_sight_of(what: Node, property: String, detection_zone: DetectionZone) -> void:
	var old_var: Node = get(property)

	if what == old_var or is_null(old_var):
		if detection_zone.collisions.size() > 0:
			set(property, detection_zone.collisions[0])
		else:
			set(property, null)
#endregion


#region Events
func _on_DetectionZone_lost(what: Node) -> void:
	lose_sight_of(what, "current_target", detection_zone)

	if what is Robber:
		if not is_null(player):
			last_target_sighting = player.global_position
		lose_sight_of(what, "player", detection_zone)


func _on_DetectionZone_saw(what: Node) -> void:
	current_target = what

	if what is Robber:
		player = what
#endregion


static func is_null(node: Node) -> bool:
	return node == null or not is_instance_valid(node)
#endregion
