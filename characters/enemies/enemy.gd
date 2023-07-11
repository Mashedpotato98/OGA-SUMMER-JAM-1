class_name Enemy
extends Character


export var walk_speed := 16.0
export var wander_time_randomization := 5.0
export var wander_distance := 128.0

var player: Robber = null
var current_target: Node2D = null
var last_target_sighting := Vector2.INF

onready var wander_timer: Timer = $WanderTimer
onready var navigation_agent: NavigationAgent2D = $NavigationAgent
onready var soft_collider: SoftCollider = $SoftCollider
onready var detection_zone: DetectionZone = $DetectionZone


func _physics_process(delta: float) -> void:
	if not stunned:
		_move()

	smooth_vel = soft_collider.get_safe_velocity(smooth_vel)
	._physics_process(delta)


func _move() -> void:
	patrol()


func _chase(target: Node2D) -> void:
	smooth_vel = global_position.direction_to(target.global_position) * speed


func wander() -> void:
	var next_location := navigation_agent.get_next_location()
	if global_position.distance_to(next_location) > navigation_agent.target_desired_distance:
		smooth_vel = global_position.direction_to(next_location) * walk_speed
	else:
		smooth_vel = Vector2()


func search() -> void:
	if global_position.distance_to(last_target_sighting) > navigation_agent.target_desired_distance:
		smooth_vel = global_position.direction_to(last_target_sighting) * speed
	else:
		last_target_sighting = Vector2.INF


func patrol() -> void:
	var wandering := false

	if not is_null(current_target):
		hand_pivot.set_target(current_target)
		_chase(current_target)
	elif last_target_sighting != Vector2.INF:
		hand_pivot.lose_target()
		search()
	else:
		hand_pivot.lose_target()
		wander()
		wandering = true

	if wandering:
		if wander_timer.is_stopped():
			_on_WanderTimer_timeout()
	elif not wander_timer.is_stopped():
		wander_timer.stop()


func start_wander_timer() -> void:
	wander_timer.start(wander_timer.wait_time + rand_range(-wander_time_randomization,
			wander_time_randomization))


# warning-ignore:shadowed_variable
func lose_sight_of(what: Node, property: String, detection_zone: DetectionZone) -> void:
	var old_var: Node = get(property)

	if what == old_var or is_null(old_var):
		if detection_zone.collisions.size() > 0:
			set(property, detection_zone.collisions[0])
		else:
			set(property, null)


static func is_null(node: Node) -> bool:
	return node == null or not is_instance_valid(node)


func _on_WanderTimer_timeout() -> void:
	var random_dir := (Vector2.RIGHT * rand_range(0.0, wander_distance)).rotated(
			rand_range(0.0, TAU))
	var wander_pos := global_position + random_dir
	navigation_agent.set_target_location(wander_pos)

	start_wander_timer()


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
