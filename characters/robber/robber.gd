# Could use state machine, but might be over kill depending on how the mechanics work.
class_name Robber extends Character


#region Members
signal code_grabbed(code: Array, from: Vector2)

const BRIBE := preload("res://characters/robber/bribe.tscn")

#region Export
@export var turn_speed := 10.0
@export var dash_speed := 128.0
@export var dash_length := 0.5
@export var cronie_spawn_distance := 24.0
#endregion

#region Variables
var dash_cooling := false
var anim_dir := Vector2.RIGHT: set = _on_anim_dir_set
var aim_dir := Vector2()
var bribing := false
var is_ready := false
var holding_trigger := false
var enabled := true: set = _on_enabled_set
#endregion

#region Onready
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get(&"parameters/playback")
@onready var dash_cool_down: Timer = $DashCoolDown
@onready var dash_sound: AudioStreamPlayer = $DashSound
@onready var dash_bar: TextureProgressBar = $DashBar
#endregion
#endregion


#region Functions
#region Overrides
func _init() -> void:
	Inventory.current_item_switched.connect(_on_Inventory_current_item_switched)
	Inventory.items_changed.connect(_on_Inventory_items_changed)


func _ready() -> void:
	spawn_cronies()

	if Inventory.items.keys().size() > 0:
		Inventory._on_current_item_set(Inventory.current_item)

	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	dash_bar.max_value = dash_cool_down.wait_time
	is_ready = true


func _input(event: InputEvent) -> void:
	if not enabled:
		return

	if event is InputEventMouseMotion:
		# Put in _physics_process() if using camera smoothing.
		var mouse_pos := get_global_mouse_position()
		aim_dir = global_position.direction_to(mouse_pos)

	if stunned:
		return

	elif event.is_action_pressed(&"switch_gun_next"):
		scroll_items(1)
	elif event.is_action_pressed(&"switch_gun_prev"):
		scroll_items(-1)


func _unhandled_input(event: InputEvent) -> void:
	if not enabled:
		return

	if event.is_action_pressed(&"shoot"):
		holding_trigger = true
	elif event.is_action_released(&"shoot"):
		holding_trigger = false


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed(&"dash") and not dash_cooling:
		dash()
	if not stunned:
		move(delta)
		turn(delta)
		if holding_trigger:
			activate_item()

	super(delta)


func _die() -> void:
	reset_stats()
	var fade := Fade.new()
	add_child(fade)
	fade.fade(Fade.FadeMode.FADE_IN, 1.0)
	await fade.finished
	get_tree().change_scene_to_file("res://ui/screens/lose_screen.tscn")
#endregion


#region Regular
func reset_stats() -> void:
	Inventory.money = Inventory.DEFAULT_MONEY
	Inventory.current_item = 0
	Inventory.items = Inventory.DEFAULT_ITEMS.duplicate()
	Inventory.cronies = []
	Inventory.first_raid = true
	Inventory.save_inventory()


func dash() -> void:
	shove(anim_dir * dash_speed, dash_length, false)
	dash_cooling = true
	dash_cool_down.start()
	hit_box.start_immunity(dash_length)
	dash_sound.play()
	dash_bar.value = dash_bar.max_value
	create_tween().tween_property(dash_bar, ^"value", 0.0, dash_cool_down.wait_time)
	animation_tree.set(&"parameters/Dash/blend_position", anim_dir)
	playback.travel(&"Dash")


func set_code(code: Array, from: Vector2) -> void:
	code_grabbed.emit(code, from)


func change_item(ITEM: PackedScene) -> void:
	super(ITEM)
	ammo = Inventory.items[ITEM.resource_path]


func clear_item() -> void:
	super.change_item(null)


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
		var cronie: Character = load(cronie_info.type).instantiate()
		get_parent().add_child.call_deferred(cronie)
		await cronie.ready

		cronie.global_position = global_position + (Vector2.RIGHT * cronie_spawn_distance).rotated(
				TAU / cronie_count * i)
		cronie.change_item(load(cronie_info.weapon))
		cronie.bribe_state = cronie.BRIBE_STATES.BRIBED


func move(_delta: float) -> void:
	var input_dir := Input.get_vector(&"left", &"right", &"up", &"down")
	smooth_vel = input_dir * speed
	anim_dir = input_dir


func turn(delta: float) -> void:
	var joy_direction := Input.get_vector(&"aim_left", &"aim_right", &"aim_up", &"aim_down")
	if joy_direction.length() > 0.0:
		aim_dir = joy_direction
	hand_pivot.rotation = lerp_angle(hand_pivot.rotation, aim_dir.angle(), turn_speed * delta)


func blink() -> void:
	var blink_duration := 0.25
	var blinks := 3
	for i in blinks:
		sprite.material.set(&"shader_param/enabled", true)
		await get_tree().create_timer(blink_duration / blinks / 2.0).timeout
		sprite.material.set(&"shader_param/enabled", false)
		await get_tree().create_timer(blink_duration / blinks / 2.0).timeout
#endregion


#region Events
func _on_anim_dir_set(value: Vector2) -> void:
	if value.length() > 0.0:
		anim_dir = value

	var state := "Run" if value.length() > 0.0 else "Idle"
	animation_tree.set(&"parameters/{0}/blend_position".format([state]), anim_dir)
	playback.travel(state)


func _on_ammo_set(value: int) -> void:
	if not is_ready:
		return

	ammo = value
	var item_path: String = item.scene_file_path
	Inventory.set_item_ammo(item_path, ammo, false)


func _on_enabled_set(value: bool) -> void:
	enabled = value
	if not enabled:
		holding_trigger = false
	set_physics_process(enabled)


func _on_Inventory_current_item_switched(item_index: int) -> void:
	var item := load(Inventory.items.keys()[item_index])
	change_item(item)
	bribing = item == BRIBE

	await RenderingServer.frame_pre_draw
	start_cool_down()


func _on_Inventory_items_changed(items: Dictionary) -> void:
	if items.size() <= 0:
		clear_item()


func _on_HitBox_dmg_taken(from: Vector2, amount: int) -> void:
	super(from, amount)
	blink()


func _on_DashCoolDown_timeout() -> void:
	dash_cooling = false


func _on_Vault_activated(_vault: StaticBody2D) -> void:
	enabled = false


func _on_UI_vault_menu_closed() -> void:
	enabled = true
#endregion
#endregion
