class_name Vault extends StaticBody2D


#region Members
signal activated(vault: Vault)

#region Constants
const MONEY_PICKUP := preload("res://pickups/money_pickup.tscn")
const CODE_PICKUP := preload("res://pickups/code_pickup.tscn")
#endregion

#region Export
@export var bundles := 10
@export var fall_duration := 0.25
@export var code_length := 6
@export var code_spawn_points: Node
#endregion

# Code format: [<true = right, false = left>, etc...]
var code := []

#region Onready
@onready var sprite: Sprite2D = $Sprite2D
@onready var min_pos: Vector2 = $MinPos.position
@onready var max_pos: Vector2 = $MaxPos.position
@onready var activation_box: Area2D = $ActivationBox
@onready var open_sound: AudioStreamPlayer2D = $OpenSound
#endregion
#endregion


#region Functions
func _ready() -> void:
	randomize()
	code = generate_code(code_length)

	if code_spawn_points != null and code_spawn_points.get_child_count() > 0:
		spawn_code_pickup()
	else:
		printerr("No vault key spawn points!")


#region Regular
func is_code_valid(code: Array) -> bool:
	if self.code == code:
		open()
		return true
	else:
		return false


func spawn_code_pickup() -> void:
	var spawn_index: int = randi() % code_spawn_points.get_child_count()
	var pos: Vector2 = code_spawn_points.get_child(spawn_index).global_position

	var code_pickup: CodePickup = CODE_PICKUP.instantiate()
	code_pickup.code = code
	add_child(code_pickup)
	code_pickup.global_position = pos


func open() -> void:
	activation_box.queue_free()
	for i in bundles:
		spawn_bundle()

	sprite.frame = 1
	open_sound.play()
	get_tree().get_nodes_in_group(&"cameras")[0].shake(4.0, 20, 0.5)


func spawn_bundle() -> void:
	var money_pickup: MoneyPickup = MONEY_PICKUP.instantiate()
	add_child(money_pickup)
	money_pickup.position = Vector2()
	randomize()
	var final_pos := Vector2(randf_range(min_pos.x, max_pos.x), randf_range(min_pos.y, max_pos.y))
	create_tween().tween_property(money_pickup, ^"position", final_pos, fall_duration
			).set_ease(Tween.EASE_OUT)
#endregion


func _on_ActivationBox_body_entered(body: Node) -> void:
	if body is Robber:
		activated.emit(self)


static func generate_code(length: int) -> Array:
	var code := []
	for i in length:
		code.append(bool(randi() % 2))

	return code
#endregion
