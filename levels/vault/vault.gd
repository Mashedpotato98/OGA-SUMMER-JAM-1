class_name Vault
extends StaticBody2D


signal activated(vault)

const MONEY_PICKUP := preload("res://pickups/money_pickup.tscn")
const CODE_PICKUP := preload("res://pickups/code_pickup.tscn")

export var bundles := 10
export var fall_duration := 0.25
export var code_length := 6
export(NodePath) var code_spawn_points

# Code format: [<true = right, false = left>, etc...]
var code := []

onready var sprite: Sprite = $Sprite
onready var min_pos: Vector2 = $MinPos.position
onready var max_pos: Vector2 = $MaxPos.position
onready var activation_box: Area2D = $ActivationBox
onready var open_sound: AudioStreamPlayer2D = $OpenSound


func _ready() -> void:
	randomize()
	code = generate_code(code_length)

	if not code_spawn_points.is_empty() and get_node(code_spawn_points).get_child_count() > 0:
		code_spawn_points = get_node(code_spawn_points)
		spawn_code_pickup()
	else:
		printerr("No vault key spawn points!")


# warning-ignore:shadowed_variable
func is_code_valid(code: Array) -> bool:
	if self.code == code:
		open()
		return true
	else:
		return false


func spawn_code_pickup() -> void:
	var spawn_index: int = randi() % code_spawn_points.get_child_count()
	var pos: Vector2 = code_spawn_points.get_child(spawn_index).global_position

	var code_pickup: CodePickup = CODE_PICKUP.instance()
	code_pickup.code = code
	add_child(code_pickup)
	code_pickup.global_position = pos


func open() -> void:
	activation_box.queue_free()
	for i in bundles:
		spawn_bundle()

	sprite.frame = 1
	open_sound.play()
	get_tree().get_nodes_in_group("cameras")[0].shake(4.0, 20, 0.5)


func spawn_bundle() -> void:
	var money_pickup: MoneyPickup = MONEY_PICKUP.instance()
	add_child(money_pickup)
	money_pickup.position = Vector2()
	randomize()
	var final_pos := Vector2(rand_range(min_pos.x, max_pos.x), rand_range(min_pos.y, max_pos.y))
	create_tween().tween_property(money_pickup, "position", final_pos, fall_duration
# warning-ignore:return_value_discarded
			).set_ease(Tween.EASE_OUT)


static func generate_code(length: int) -> Array:
# warning-ignore:shadowed_variable
	var code := []
	for i in length:
		code.append(bool(randi() % 2))

	return code


func _on_ActivationBox_body_entered(body: Node) -> void:
	if body is Robber:
		emit_signal("activated", self)
