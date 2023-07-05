# Could use state machine, but might be over kill depending on how the mechanics work.
class_name Robber
extends Character


export var turn_speed := 10.0
export var dash_speed := 128.0
export var dash_length := 0.5

var dash_colling := false
var anim_dir := Vector2.RIGHT setget _on_anim_dir_set
var aim_dir := Vector2()
var guns := []

onready var animation_tree: AnimationTree = $AnimationTree
onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
onready var interaction_zone: Area2D = $InteractZone
onready var dash_cool_down: Timer = $DashCoolDown


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Put in _physics_process() if using camera smoothing.
		var mouse_pos := get_global_mouse_position()
		aim_dir = global_position.direction_to(mouse_pos)

	if stunned:
		return

	if event.is_action_pressed("dash") and not dash_colling:
		shove(anim_dir * dash_speed, dash_length)
		dash_colling = true
		dash_cool_down.start()
		hit_box.start_immunity(dash_length)
	elif event.is_action_pressed("bribe"):
		bribe()



func _physics_process(delta: float) -> void:
	if not stunned:
		move(delta)
		turn(delta)
		if Input.is_action_pressed("shoot"):
# warning-ignore:return_value_discarded
			activate_item()

	._physics_process(delta)


func move(_delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	smooth_vel = input_dir * speed
	self.anim_dir = input_dir


func turn(delta: float) -> void:
	var joy_direction := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if joy_direction.length() > 0.0:
		aim_dir = joy_direction
	hand_pivot.rotation = lerp_angle(hand_pivot.rotation, aim_dir.angle(), turn_speed * delta)


func bribe() -> void:
	var bodies := interaction_zone.get_overlapping_bodies()
	if bodies.size() <= 0 or Inventory.cronies.size() >= Inventory.MAX_CRONIES:
		print(Inventory.cronies)
		return

	var cop: Node2D = bodies[0]
	cop.bribed = true



func add_item(ITEM: PackedScene) -> void:
	change_item(ITEM)
	if Inventory.items.has(ITEM):
		Inventory.items[ITEM] += 1
	else:
		Inventory.items[ITEM] = 1


func blink() -> void:
	var blink_duration := 0.25
	var blinks := 3
	for i in blinks:
		sprite.material.set("shader_param/enabled", true)
		yield(get_tree().create_timer(blink_duration / blinks / 2.0), "timeout")
		sprite.material.set("shader_param/enabled", false)
		yield(get_tree().create_timer(blink_duration / blinks / 2.0), "timeout")


func _on_HitBox_dmg_taken(from: Vector2, amount: int) -> void:
	._on_HitBox_dmg_taken(from, amount)
	blink()


func _on_anim_dir_set(value: Vector2) -> void:
	if value.length() > 0.0:
		anim_dir = value

	var state := "Walk" if value.length() > 0.0 else "Idle"
	animation_tree.set("parameters/{0}/blend_position".format([state]), anim_dir)
	playback.travel(state)


func _on_DashCoolDown_timeout() -> void:
	dash_colling = false
