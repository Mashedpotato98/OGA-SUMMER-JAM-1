class_name Enemy
extends Character


export var walk_speed := 16.0
export var wander_time_randomization := 5.0
export var wander_distance := 128.0
export var bribed_texture: Texture

var target: Node2D = null
var last_target_sighting := Vector2.INF
var bribed := false setget _on_bribed_set

onready var wander_timer: Timer = $WanderTimer
onready var navigation_agent: NavigationAgent2D = $NavigationAgent
onready var soft_collider: SoftCollider = $SoftCollider
onready var detection_zone: DetectionZone = $DetectionZone


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
	if global_position.distance_to(last_target_sighting) > navigation_agent.target_desired_distance:
		smooth_vel = global_position.direction_to(last_target_sighting) * speed
	else:
		last_target_sighting = Vector2.INF


func move() -> void:
	var wandering := false
	if not is_null(target):
		_chase()
	elif last_target_sighting != Vector2.INF:
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


func is_null(node: Node) -> bool:
	return target == null or not is_instance_valid(node)


func _on_bribed_set(value: bool) -> void:
	if bribed == value:
		return
	bribed = value

	if bribed:
		sprite.texture = bribed_texture
		Inventory.cronies.append(item.filename)


func _on_WanderTimer_timeout() -> void:
	var random_dir := (Vector2.RIGHT * rand_range(0.0, wander_distance)).rotated(
			rand_range(0.0, TAU))
	var wander_pos := global_position + random_dir
	navigation_agent.set_target_location(wander_pos)

	start_wander_timer()


func _on_DetectionZone_lost(what: Node) -> void:
	if what == target or is_null(target):
		if is_null(target):# Redundent
			last_target_sighting = target.global_position
		if detection_zone.collisions.size() > 0:
			target = detection_zone.collisions[0]
		else:
			target = null


func _on_DetectionZone_saw(what: Node) -> void:
	target = what
