class_name Vault
extends StaticBody2D


signal activated(vault)

const MONEY_PICKUP := preload("res://pickups/money_pickup.tscn")

export var bundles := 10
export var fall_duration := 0.25
export var code_length := 6

# Code format: [<true = right, false = left>, etc...]
var code := []

onready var min_pos: Vector2 = $MinPos.position
onready var max_pos: Vector2 = $MaxPos.position
onready var activation_box: Area2D = $ActivationBox


func _ready() -> void:
	randomize()
	code = generate_code(code_length)


# warning-ignore:shadowed_variable
func is_code_valid(code: Array) -> bool:
	if self.code == code:
		open()
		return true
	else:
		return false


func open() -> void:
	activation_box.queue_free()
	for i in bundles:
		spawn_bundle()


func spawn_bundle() -> void:
	var money_pickup: MoneyPickup = MONEY_PICKUP.instance()
	add_child(money_pickup)
	money_pickup.position = Vector2()
	randomize()
	var final_pos := Vector2(rand_range(min_pos.x, max_pos.x), rand_range(min_pos.y, max_pos.y))
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
# warning-ignore:return_value_discarded
	tween.tween_property(money_pickup, "position", final_pos, fall_duration)


static func generate_code(length: int) -> Array:
# warning-ignore:shadowed_variable
	var code := []
	for i in length:
		code.append(bool(randi() % 2))

	return code


func _on_ActivationBox_body_entered(body: Node) -> void:
	if body is Robber:
		emit_signal("activated", self)
