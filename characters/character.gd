class_name Character extends CharacterBody2D


#region Members
#region Signals
signal cool_down_started(item: String, duration: float)
signal max_hp_changed(max_hp: int)
signal hp_changed(hp: int)
signal died
#endregion

#region Export
@export var acceleration := 128.0
@export var speed := 32.0
@export var walk_speed := 16.0
@export var hit_force := 64.0
@export var kickback := 32.0
@export var kickback_time := 0.1
@export var hurt_bounce := 64.0
@export var hurt_bounce_time := 0.25
@export var desired_distance := 4.0

@export var max_hp := 3: set = _on_max_hp_set
@export var hp := 3: set = _on_hp_set
@export var item: Node = null
@export var ammo := -1
@export_enum("cop", "robber", "all") var type := "cop"
@export var DEATH_EFFECT: PackedScene = null
#endregion

#region Variables
var smooth_vel := Vector2()
var stunned := false
#endregion

#region Onready
@onready var wander_point := global_position
@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_box: HitBox = $HitBox
@onready var hand_pivot: Marker2D = $HandPivot
@onready var hand: Marker2D = $HandPivot/Hand
@onready var wall_detector: RayCast2D = $WallDetector
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
#endregion
#endregion


#region Functions
#region Overrides
func _physics_process(delta: float) -> void:
	if smooth_vel != Vector2.INF:
		velocity = velocity.move_toward(smooth_vel, acceleration * delta)
	move_and_slide()


# Overwrite. Will queue_free() by default.
func _die() -> void:
	queue_free()
#endregion


#region Regular
func change_item(ITEM: PackedScene) -> void:
	if item != null:
		item.queue_free()
		#await item.tree_exited
		#item = null

	if ITEM != null:
		item = ITEM.instantiate()
		hand.add_child.call_deferred(item)
		await item.ready
		item.set_owner(self)

	#assert(hand.get_child_count() <= 1)


func activate_item() -> bool:
	if item == null or ammo == 0:# Note: not ammo <= 0. this allows for using -1 to indicate no limit.
		return false
	if not item.has_method(&"activate"):
		return false

	if item.activate():
		start_cool_down()
		if item is Gun:
			ammo -= 1
		return true

	return false


func start_cool_down() -> void:
	if is_instance_valid(item) and item.has_node(^"CoolDown"):
		cool_down_started.emit(item.scene_file_path, item.get_node(^"CoolDown").wait_time)


func shove(vel: Vector2, duration: float, stun := true) -> void:
	if stunned:
		return
	velocity = vel
	smooth_vel = Vector2.INF

	if stun:
		stunned = true
		await get_tree().create_timer(duration).timeout
		stunned = false


func wander() -> void: # Built to be called every frame.
	if global_position.distance_to(wander_point) < desired_distance:
		choose_wander_point()

	smooth_vel = global_position.direction_to(wander_point) * walk_speed


func choose_wander_point() -> void:
	var wander_points := get_tree().get_nodes_in_group(&"wander_points")
	wander_points.shuffle()

	for wander_point in wander_points:
		var wander_point_pos: Vector2 = wander_point.global_position
		wall_detector.target_position = to_local(wander_point_pos)
		wall_detector.force_raycast_update()
		if not wall_detector.is_colliding():
			self.wander_point = wander_point_pos
			break
#endregion


#region Events
func _on_max_hp_set(value: int) -> void:
	max_hp = value
	_on_hp_set(hp)
	max_hp_changed.emit(max_hp)


func _on_hp_set(value: int) -> void:
	hp = mini(value, max_hp)
	if hp <= 0:
		if DEATH_EFFECT != null:
			var death_effect: Node = DEATH_EFFECT.instantiate()
			get_tree().current_scene.add_child(death_effect)
			if death_effect is Node2D:
				death_effect.global_position = global_position

		_die()
		died.emit()

	hp_changed.emit(hp)


func _on_HitBox_dmg_taken(from: Vector2, amount: int) -> void:
	shove(from.direction_to(global_position) * hurt_bounce, hurt_bounce_time)
	hp -= amount
	hurt_sound.play()
#endregion
#endregion
