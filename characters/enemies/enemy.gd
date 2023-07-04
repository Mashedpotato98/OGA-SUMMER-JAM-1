class_name Enemy
extends Character


export var walk_speed := 16.0
export var wander_time_randomization := 5.0
export var wander_distance := 128.0

var robber: Robber = null
var last_robber_sighting := Vector2.INF

onready var wander_timer: Timer = $WanderTimer
onready var navigation_agent: NavigationAgent2D = $NavigationAgent
onready var soft_collider: SoftCollider = $SoftCollider


func _physics_process(delta: float) -> void:
	if not stunned:
		move()

	smooth_vel = soft_collider.get_safe_velocity(smooth_vel)
	._physics_process(delta)


func _chase() -> void:
	pass


func wander() -> void:
	var next_location := navigation_agent.get_next_location()
	if global_position.distance_to(next_location) > navigation_agent.target_desired_distance:
		smooth_vel = global_position.direction_to(next_location) * walk_speed
	else:
		smooth_vel = Vector2()


func search() -> void:
	if global_position.distance_to(last_robber_sighting) > navigation_agent.target_desired_distance:
		smooth_vel = global_position.direction_to(last_robber_sighting) * speed
	else:
		last_robber_sighting = Vector2.INF


func move() -> void:
	var wandering := false
	if robber != null and is_instance_valid(robber):
		_chase()
	elif last_robber_sighting != Vector2.INF:
		search()
	else:
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
func _on_DetectionZone_robber_entered(robber: Robber) -> void:
	self.robber = robber


func _on_DetectionZone_robber_exited() -> void:
	if not is_instance_valid(robber):
		return

	last_robber_sighting = robber.global_position
	robber = null


func _on_WanderTimer_timeout() -> void:
	var random_dir := (Vector2.RIGHT * rand_range(0.0, wander_distance)).rotated(
			rand_range(0.0, TAU))
	var wander_pos := global_position + random_dir
	navigation_agent.set_target_location(wander_pos)

	start_wander_timer()
