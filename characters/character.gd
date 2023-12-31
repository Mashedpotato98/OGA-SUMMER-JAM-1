class_name Character
extends KinematicBody2D


signal cool_down_started(item, duration)
signal max_hp_changed(max_hp)
signal hp_changed(hp)
signal died

export var acceleration := 128.0
export var speed := 32.0
export var walk_speed := 16.0
export var hit_force := 64.0
export var kickback := 32.0
export var kickback_time := 0.1
export var hurt_bounce := 64.0
export var hurt_bounce_time := 0.25
export var desired_distance := 4.0

export var max_hp := 3 setget _on_max_hp_set
export var hp := 3 setget _on_hp_set
export(NodePath) var item = NodePath()
export var ammo := -1 setget _on_ammo_set
export(String, "cop", "robber", "all") var type := "cop"
export var DEATH_EFFECT: PackedScene = null

# Auto-switches based on what was last set.
var smoothing_enabled := true
var smooth_vel := Vector2() setget _on_smooth_vel_set
var velocity := Vector2() setget _on_velocity_set

var stunned := false

onready var wander_point := global_position
onready var sprite: Sprite = $Sprite
onready var hit_box: HitBox = $HitBox
onready var hand_pivot: Position2D = $HandPivot
onready var hand: Position2D = hand_pivot.get_node("Hand")
onready var wall_detector: RayCast2D = $WallDetector
onready var hurt_sound: AudioStreamPlayer2D = $HurtSound


func _ready() -> void:
	if not item.is_empty():
		item = get_node(item)


func _physics_process(delta: float) -> void:
	if smoothing_enabled:
		velocity = velocity.move_toward(smooth_vel, acceleration * delta)
	velocity = move_and_slide(velocity)


# Overwrite. Will queue_free() by default.
func _die() -> void:
	queue_free()


func change_item(ITEM: PackedScene) -> void:
	if item != null and is_instance_valid(item) and not item is NodePath:
		item.queue_free()
		yield(item, "tree_exited")
		item = null

	if ITEM != null:
		item = ITEM.instance()
		hand.call_deferred("add_child", item)
		yield(item, "ready")
		item.set_owner(self)

	# Bad code, but fastest fix to weird bug with two guns.
	yield(get_tree().create_timer(0.1), "timeout")
	if hand.get_child_count() > 1:
		hand.get_child(0).queue_free()


func activate_item() -> bool:
	if item == null or not is_instance_valid(item) or item is NodePath or ammo == 0:# Note: not ammo <= 0. this allows for using -1 to indicate no limit.
		return false
	if not item.has_method("activate"):
		return false

	if item.activate():
		start_cool_down()
		if item is Gun:
			self.ammo -= 1

		return true
	return false


func start_cool_down() -> void:
	if is_instance_valid(item) and item.has_node("CoolDown"):
		emit_signal("cool_down_started", item.filename, item.get_node("CoolDown").wait_time)


func shove(vel: Vector2, duration: float) -> void:
	if stunned:
		return
	velocity = vel

	stunned = true
	yield(get_tree().create_timer(duration), "timeout")
	stunned = false


func wander() -> void:
	if global_position.distance_to(wander_point) < desired_distance:
		choose_wander_point()

	smooth_vel = global_position.direction_to(wander_point) * walk_speed


func choose_wander_point() -> void:
	wall_detector.enabled = true
	var wander_points := get_tree().get_nodes_in_group("wander_points")
	wander_points.shuffle()

# warning-ignore:shadowed_variable
	for wander_point in wander_points:
		var wander_point_pos: Vector2 = wander_point.global_position
		wall_detector.cast_to = to_local(wander_point_pos)
		wall_detector.force_raycast_update()
		if not wall_detector.is_colliding():
			self.wander_point = wander_point_pos
			break

	wall_detector.enabled = false


func _on_max_hp_set(value: int) -> void:
	max_hp = value
	_on_hp_set(hp)
	emit_signal("max_hp_changed", max_hp)


func _on_hp_set(value: int) -> void:
# warning-ignore:narrowing_conversion
	hp = min(value, max_hp)
	if hp <= 0:
		if DEATH_EFFECT != null:
			var death_effect: Node = DEATH_EFFECT.instance()
			get_tree().current_scene.add_child(death_effect)
			if death_effect is Node2D:
				death_effect.global_position = global_position

		_die()
		emit_signal("died")

	emit_signal("hp_changed", hp)


func _on_smooth_vel_set(value: Vector2) -> void:
	smooth_vel = value
	smoothing_enabled = true


func _on_velocity_set(value: Vector2) -> void:
	velocity = value
	smoothing_enabled = false


func _on_ammo_set(value: int) -> void:
	ammo = value


func _on_HitBox_dmg_taken(from: Vector2, amount: int) -> void:
	shove(from.direction_to(global_position) * hurt_bounce, hurt_bounce_time)
	self.hp -= amount
	hurt_sound.play()
