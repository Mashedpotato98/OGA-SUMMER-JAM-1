# Could use state machine, but might be over kill depending on how the mechanics work.
class_name Robber
extends Character


const BRIBE := preload("res://characters/robber/bribe.tscn")

export var turn_speed := 10.0
export var dash_speed := 128.0
export var dash_length := 0.5
export var cronie_spawn_distance := 24.0

var dash_colling := false
var anim_dir := Vector2.RIGHT setget _on_anim_dir_set
var aim_dir := Vector2()
var bribing := false
var is_ready := false
var holding_trigger := false

onready var animation_tree: AnimationTree = $AnimationTree
onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
onready var dash_cool_down: Timer = $DashCoolDown


func _init() -> void:
# warning-ignore:return_value_discarded
	Inventory.connect("current_item_switched", self, "_on_Inventory_current_item_switched")
# warning-ignore:return_value_discarded
	Inventory.connect("items_changed", self, "_on_Inventory_items_changed")


func _ready() -> void:
	._ready()
	spawn_cronies()

	if Inventory.items.keys().size() > 0:
		Inventory._on_current_item_set(Inventory.current_item)

	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	is_ready = true


func _input(event: InputEvent) -> void:
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
	elif event.is_action_pressed("switch_gun_next"):
		scroll_items(1)
	elif event.is_action_pressed("switch_gun_prev"):
		scroll_items(-1)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		holding_trigger = true
	elif event.is_action_released("shoot"):
		holding_trigger = false


func _physics_process(delta: float) -> void:
	if not stunned:
		move(delta)
		turn(delta)
		if holding_trigger:
# warning-ignore:return_value_discarded
			activate_item()

	._physics_process(delta)


func _die() -> void:
	var fade := Fade.new()
	add_child(fade)
	fade.fade(Fade.FADE_IN, 1.0)
	yield(fade, "finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ui/screens/lose_screen.tscn")


func change_item(ITEM: PackedScene) -> void:
	.change_item(ITEM)
	ammo = Inventory.items[ITEM.resource_path]


func clear_item() -> void:
	.change_item(null)


func scroll_items(direction: int) -> void:
	var item_count := Inventory.items.keys().size()
	if item_count <= 0:
		return

	Inventory.current_item += direction


func add_item(ITEM: PackedScene) -> void:
	var item_ammo: int = Inventory.items_list[ITEM.resource_path].ammo
	if Inventory.items.has(ITEM.resource_path):
		Inventory.set_item_ammo(ITEM.resource_path, item_ammo)
	else:
		Inventory.set_item_ammo(ITEM.resource_path, item_ammo, false)

	Inventory.current_item = Inventory.items.keys().find(ITEM.resource_path)


func spawn_cronies() -> void:
	var cronie_count := Inventory.cronies.size()
	for i in cronie_count:
		var cronie_info: Dictionary = Inventory.cronies[i]
		var cronie: Character = load(cronie_info.type).instance()
		get_parent().call_deferred("add_child", cronie)
		yield(cronie, "ready")
		cronie.global_position = global_position + (Vector2.RIGHT * cronie_spawn_distance).rotated(
				TAU / cronie_count * i)
		cronie.change_item(load(cronie_info.weapon))
		cronie.bribe_state = cronie.BRIBE_STATES.BRIBED


func move(_delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	smooth_vel = input_dir * speed
	self.anim_dir = input_dir


func turn(delta: float) -> void:
	var joy_direction := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if joy_direction.length() > 0.0:
		aim_dir = joy_direction
	hand_pivot.rotation = lerp_angle(hand_pivot.rotation, aim_dir.angle(), turn_speed * delta)


func blink() -> void:
	var blink_duration := 0.25
	var blinks := 3
	for i in blinks:
		sprite.material.set("shader_param/enabled", true)
		yield(get_tree().create_timer(blink_duration / blinks / 2.0), "timeout")
		sprite.material.set("shader_param/enabled", false)
		yield(get_tree().create_timer(blink_duration / blinks / 2.0), "timeout")


func _on_anim_dir_set(value: Vector2) -> void:
	if value.length() > 0.0:
		anim_dir = value

	var state := "Walk" if value.length() > 0.0 else "Idle"
	animation_tree.set("parameters/{0}/blend_position".format([state]), anim_dir)
	playback.travel(state)


func _on_ammo_set(value: int) -> void:
	if not is_ready:
		return

	ammo = value
	var item_path: String = item.filename
	Inventory.set_item_ammo(item_path, ammo, false)


func _on_Inventory_current_item_switched(item_index: int) -> void:
	var item := load(Inventory.items.keys()[item_index])
	change_item(item)
	bribing = item == BRIBE


func _on_Inventory_items_changed(items: Dictionary) -> void:
	if items.size() <= 0:
		clear_item()


func _on_HitBox_dmg_taken(from: Vector2, amount: int) -> void:
	._on_HitBox_dmg_taken(from, amount)
	blink()


func _on_DashCoolDown_timeout() -> void:
	dash_colling = false
