class_name Cop
extends Enemy


signal player_reached

enum BRIBE_STATES {
	INNOCENT,
	BEING_BRIBED,
	BRIBED,
}

const GUNS := [
	preload("res://guns/g36c/g36c.tscn"),
	preload("res://guns/pistol/pistol.tscn"),
	preload("res://guns/shot_gun/shot_gun.tscn"),
	preload("res://guns/submachine_gun/submachine_gun.tscn"),
]

export var shoot_margin := 0.25
export var min_circle_distance := 64.0
export var max_circle_distance := 96.0
export var bribed_texture: Texture
export var follow_distance := 24.0

var bribe_state: int = BRIBE_STATES.INNOCENT setget _on_bribe_state_set
var cop: Node2D = null
var circle_dir := (randi() % 2) * 2 - 1# -1 or 1

onready var circle_distance := rand_range(min_circle_distance, max_circle_distance)
onready var cop_detection_zone: DetectionZone = $CopDetectionZone
onready var cop_detection_zone_collision_shape: CollisionShape2D = cop_detection_zone.get_node(
		"CollisionShape2D")


func _ready() -> void:
	._ready()
	change_item(GUNS[randi() % GUNS.size()])


func _die() -> void:
	if bribe_state == BRIBE_STATES.BRIBED:
		for i in Inventory.cronies.size():
			var cronie: Dictionary = Inventory.cronies[i]
			if (cronie.type == filename
					and true if not cronie.has("weapon") else cronie.weapon == item.filename):
				Inventory.cronies.remove(i)
				Inventory._on_cronies_set(Inventory.cronies)
				break
	queue_free()


func _chase(target: Node2D) -> void:
	var direction := global_position.direction_to(target.global_position)
	var distance := global_position.distance_to(target.global_position)

	if distance > circle_distance:
		smooth_vel = direction * speed
	else:
		var max_rot := PI * circle_dir
		var distance_scale := (-distance + circle_distance) / circle_distance
		smooth_vel = direction.rotated(max_rot * distance_scale) * speed

	var aim_direction := global_position.direction_to(target.global_position)
	if hand_pivot.global_transform.x.distance_to(aim_direction) <= shoot_margin:
# warning-ignore:return_value_discarded
		activate_item()


func _move() -> void:
	match bribe_state:
		BRIBE_STATES.BRIBED:
			bribed()
		BRIBE_STATES.BEING_BRIBED:
			being_bribed()
		BRIBE_STATES.INNOCENT:
			var coast_clear := cop_detection_zone.collisions.size() <= 0
			if not is_null(player) and player is Robber and player.bribing and coast_clear:
				self.bribe_state = BRIBE_STATES.BEING_BRIBED
			else:
				patrol()


func follow_player() -> void:
	if global_position.distance_to(player.global_position) > follow_distance:
		smooth_vel = global_position.direction_to(player.global_position) * speed
	else:
		smooth_vel = Vector2()
		emit_signal("player_reached")


func bribed() -> void:
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


func being_bribed() -> void:
	if is_null(player) or cop_detection_zone.collisions.size() > 0 or not player.bribing:
		self.bribe_state = BRIBE_STATES.INNOCENT
	else:
		hand_pivot.lose_target()
		follow_player()


func _on_bribe_state_set(value: int) -> void:
	bribe_state = value

	var bribed: bool = bribe_state == BRIBE_STATES.BRIBED
	set_collision_layer_bit(1, bribed)
	set_collision_layer_bit(2, not bribed)
	type = "robber" if bribed else "cop"
	if bribed:
		sprite.texture = bribed_texture


func _on_Cop_player_reached() -> void:
	if bribe_state != BRIBE_STATES.BEING_BRIBED:
		return

	self.bribe_state = BRIBE_STATES.BRIBED
	var cronie_data := {"type": filename}
	if item != null and not item is NodePath:
		cronie_data.weapon = item.filename
	Inventory.cronies.append(cronie_data)
	Inventory.money -= Inventory.items_list[Inventory.BRIBE_PATH].prices[0]


func _on_DetectionZone_lost(what: Node) -> void:
	if bribe_state == BRIBE_STATES.BRIBED:
		return
	._on_DetectionZone_lost(what)


func _on_CopDetectionZone_lost(what: Node) -> void:
	lose_sight_of(what, "cop", cop_detection_zone)


func _on_CopDetectionZone_saw(what: Node) -> void:
	cop = what


func _on_BounceZone_body_entered(_body: Node) -> void:
	circle_dir = -circle_dir
