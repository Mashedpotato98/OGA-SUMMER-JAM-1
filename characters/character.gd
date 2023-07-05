class_name Character
extends KinematicBody2D


signal max_hp_changed(max_hp)
signal hp_changed(hp)
signal died

export var acceleration := 128.0
export var speed := 32.0
export var hit_force := 64.0
export var kickback := 32.0
export var kickback_time := 0.1

export var max_hp := 3 setget _on_max_hp_set
export var hp := 3 setget _on_hp_set
export(NodePath) var item = NodePath()
export var ammo := -1
export(String, "cop", "robber") var type := "cop"

# Auto-switches based on what was last set.
var smoothing_enabled := true
var smooth_vel := Vector2() setget _on_smooth_vel_set
var velocity := Vector2() setget _on_velocity_set

var stunned := false

onready var sprite: Sprite = $Sprite
onready var hit_box: HitBox = $HitBox
onready var hand_pivot: Position2D = $HandPivot
onready var hand: Position2D = hand_pivot.get_node("Hand")


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
	if item != null and not item is NodePath:
		item.queue_free()

	item = ITEM.instance()
	hand.add_child(item)
	item.set_owner(self)


func activate_item() -> bool:
	if item == null or item is NodePath or ammo == 0:# Note: not ammo <= 0. this allows for using -1 to indicate no limit.
		return false

	if item.activate():
		if item is Gun:
			ammo -= 1
			shove(-hand_pivot.global_transform.x * kickback, kickback_time)
		return true
	return false


func shove(vel: Vector2, duration: float) -> void:
	if stunned:
		return
	velocity = vel

	stunned = true
	yield(get_tree().create_timer(duration), "timeout")
	stunned = false


func _on_max_hp_set(value: int) -> void:
	max_hp = value
	_on_hp_set(hp)
	emit_signal("max_hp_changed", max_hp)


func _on_hp_set(value: int) -> void:
# warning-ignore:narrowing_conversion
	hp = min(value, max_hp)
	if hp <= 0:
		_die()
		emit_signal("died")
	emit_signal("hp_changed", hp)


func _on_smooth_vel_set(value: Vector2) -> void:
	smooth_vel = value
	smoothing_enabled = true


func _on_velocity_set(value: Vector2) -> void:
	velocity = value
	smoothing_enabled = false


func _on_HitBox_dmg_taken(from: Vector2, amount: int) -> void:
	shove(from.direction_to(global_position) * kickback, kickback_time)
	self.hp -= amount
