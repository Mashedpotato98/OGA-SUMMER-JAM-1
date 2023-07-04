class_name Cop
extends Enemy


export var shoot_margin := 0.25
export var min_circle_distance := 64.0
export var max_circle_distance := 96.0

var circle_dir := (randi() % 2) * 2 - 1# -1 or 1
var bribed := false setget _on_bribed_set

onready var circle_distance := rand_range(min_circle_distance, max_circle_distance)


func _process(_delta: float) -> void:
	if robber == null or not is_instance_valid(robber):
		return

	var direction := global_position.direction_to(robber.global_position)
	if hand_pivot.global_transform.x.distance_to(direction) <= shoot_margin:
# warning-ignore:return_value_discarded
		pull_trigger()


func _chase() -> void:
	var direction := global_position.direction_to(robber.global_position)
	var distance := global_position.distance_to(robber.global_position)

	if distance > circle_distance:
		smooth_vel = direction * speed
	else:
		var max_rot := PI * circle_dir
		var distance_scale := (-distance + circle_distance) / circle_distance
		smooth_vel = direction.rotated(max_rot * distance_scale) * speed

	$DirectionVisualizer.cast_to = smooth_vel# temp


func _on_bribed_set(value: bool) -> void:
	bribed = value


func _on_WallDetector_body_entered(_body: Node) -> void:
	circle_dir = -circle_dir
