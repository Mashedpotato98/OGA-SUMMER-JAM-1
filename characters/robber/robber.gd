# Could use state machine, but might be over kill depending on how the mechanics work.
class_name Robber
extends Character


export var turn_speed := 10.0
export var dash_speed := 128.0
export var dash_length := 0.5
export var kickback := 32.0
export var kickback_time := 0.1

var anim_dir := Vector2.RIGHT setget _on_anim_dir_set
var aim_dir := Vector2()
var guns := []

onready var animation_tree: AnimationTree = $AnimationTree
onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
onready var hit_box: HitBox = $HitBox


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Put in _physics_process() if using camera smoothing.
		var mouse_pos := get_global_mouse_position()
		aim_dir = global_position.direction_to(mouse_pos)
	elif event.is_action_pressed("dash"):
		shove(anim_dir * dash_speed, dash_length)
		hit_box.start_immunity(dash_length)


func _physics_process(delta: float) -> void:
	._physics_process(delta)
	move(delta)
	turn(delta)

	if Input.is_action_pressed("shoot"):
		if pull_trigger():
			shove(-aim_dir * kickback, kickback_time)


func move(_delta: float) -> void:
	if stunned:
		return

	var input_dir := Input.get_vector("left", "right", "up", "down")
	smooth_vel = input_dir * speed
	self.anim_dir = input_dir


func turn(delta: float) -> void:
	hand_pivot.rotation = lerp_angle(hand_pivot.rotation, aim_dir.angle(), turn_speed * delta)


func change_gun() -> void:
	pass


func add_item(ITEM: PackedScene) -> void:
	if gun != null and not gun is NodePath:
		gun.queue_free()

	gun = ITEM.instance()
	hand.add_child(gun)
	guns.append(ITEM)


func _on_anim_dir_set(value: Vector2) -> void:
	if value.length() > 0.0:
		anim_dir = value

	var state := "Walk" if value.length() > 0.0 else "Idle"
	animation_tree.set("parameters/{0}/blend_position".format([state]), anim_dir)
	playback.travel(state)
