class_name Enemy
extends Character


enum BRIBE_STATES {
	INNOCENT,
	BEING_BRIBED,
	BRIBED,
}

export var walk_speed := 16.0
export var wander_time_randomization := 5.0
export var wander_distance := 128.0
export var bribed_texture: Texture
export var follow_distance := 24.0

var player: Robber = null
var innocent_state_taget: Node2D = null
var cop: Node2D = null setget test
func test(value):
	cop = value
	if not is_null(cop):
		assert(not cop is Robber)
var last_target_sighting := Vector2.INF
var bribe_state: int = BRIBE_STATES.INNOCENT setget _on_bribe_state_set

onready var wander_timer: Timer = $WanderTimer
onready var navigation_agent: NavigationAgent2D = $NavigationAgent
onready var soft_collider: SoftCollider = $SoftCollider
onready var detection_zone: DetectionZone = $DetectionZone
onready var cop_detection_zone: DetectionZone = $CopDetectionZone
onready var cop_detection_zone_collision_shape: CollisionShape2D = cop_detection_zone.get_node("CollisionShape2D")


func _physics_process(delta: float) -> void:
	if not stunned:
		move()

	smooth_vel = soft_collider.get_safe_velocity(smooth_vel)
	._physics_process(delta)


func _die() -> void:
	if bribe_state == BRIBE_STATES.BRIBED:
		for i in Inventory.cronies.size():
			var cronie: Dictionary = Inventory.cronies[i]
			if cronie.type == filename and cronie.weapon == item.filename:
				Inventory.cronies.remove(i)
				break
	queue_free()


func _chase(_target: Node2D) -> void:
	pass


func follow_player() -> void:
	if global_position.distance_to(player.global_position) > follow_distance:
		smooth_vel = global_position.direction_to(player.global_position) * speed
	else:
		smooth_vel = Vector2()
		if bribe_state == BRIBE_STATES.BEING_BRIBED:
			self.bribe_state = BRIBE_STATES.BRIBED
			Inventory.cronies.append({"type": filename, "weapon": item.filename})
			Inventory.money -= Inventory.BRIBE_COST


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
	match bribe_state:
		BRIBE_STATES.BRIBED:
			state_bribed()
		BRIBE_STATES.BEING_BRIBED:
			state_being_bribed()
		BRIBE_STATES.INNOCENT:
			state_innocent()


func state_bribed() -> void:
	var attacking := false
	if not is_null(cop):# Might be able to use ternary if to make simpler
		if cop is KinematicBody2D:
			if cop.bribe_state == cop.BRIBE_STATES.INNOCENT:
				hand_pivot.set_target(cop)
				_chase(cop)
				attacking = true
		else:
			hand_pivot.set_target(cop)
			_chase(cop)
			attacking = true

	if not attacking:
		hand_pivot.lose_target()
		if not is_null(player):
			follow_player()
		else:
			smooth_vel = Vector2()


func state_being_bribed() -> void:
	if is_null(player) or cop_detection_zone.collisions.size() > 0 or not player.bribing:
		self.bribe_state = BRIBE_STATES.INNOCENT
	else:
		hand_pivot.lose_target()
		follow_player()


func state_innocent() -> void:
	var wandering := false

	var coast_clear := cop_detection_zone.collisions.size() <= 0
	if not is_null(player) and player is Robber and player.bribing and coast_clear:
		self.bribe_state = BRIBE_STATES.BEING_BRIBED
	if not is_null(innocent_state_taget):
		hand_pivot.set_target(innocent_state_taget)
		_chase(innocent_state_taget)
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


# warning-ignore:shadowed_variable
func lose_sight_of(what: Node, property: String, detection_zone: DetectionZone) -> void:
	var old_var: Node = get(property)
	if old_var is Robber and bribe_state == BRIBE_STATES.BEING_BRIBED:
		bribe_state = BRIBE_STATES.INNOCENT

	if what == old_var or is_null(old_var):
		if detection_zone.collisions.size() > 0:
			set(property, detection_zone.collisions[0])
		else:
			set(property, null)


static func is_null(node: Node) -> bool:
	return node == null or not is_instance_valid(node)


func _on_bribe_state_set(value: int) -> void:
	bribe_state = value

	var bribed: bool = bribe_state == BRIBE_STATES.BRIBED
	set_collision_layer_bit(1, bribed)
	set_collision_layer_bit(2, not bribed)
	type = "robber" if bribed else "cop"
	if bribed:
		sprite.texture = bribed_texture


func _on_WanderTimer_timeout() -> void:
	var random_dir := (Vector2.RIGHT * rand_range(0.0, wander_distance)).rotated(
			rand_range(0.0, TAU))
	var wander_pos := global_position + random_dir
	navigation_agent.set_target_location(wander_pos)

	start_wander_timer()


func _on_DetectionZone_lost(what: Node) -> void:
	lose_sight_of(what, "innocent_state_taget", detection_zone)
	if what is Robber and bribe_state != BRIBE_STATES.BRIBED:
		if not is_null(player):
			last_target_sighting = player.global_position
		lose_sight_of(what, "player", detection_zone)


func _on_DetectionZone_saw(what: Node) -> void:
	innocent_state_taget = what
	if what is Robber:
		player = what


func _on_CopDetectionZone_lost(what: Node) -> void:
	lose_sight_of(what, "cop", cop_detection_zone)


func _on_CopDetectionZone_saw(what: Node) -> void:
	assert(not what is Robber)
	cop = what
