class_name Cop
extends Enemy


const COP_BRIBED := preload("res://characters/enemies/cop/cop_bribed.png")

export var shoot_margin := 0.25
export var min_circle_distance := 64.0
export var max_circle_distance := 96.0

var circle_dir := (randi() % 2) * 2 - 1# -1 or 1

onready var circle_distance := rand_range(min_circle_distance, max_circle_distance)


func _chase(target: Node2D) -> void:
	var direction := global_position.direction_to(target.global_position)
	var distance := global_position.distance_to(target.global_position)

	if distance > circle_distance:
		smooth_vel = direction * speed
	else:
		var max_rot := PI * circle_dir
		var distance_scale := (-distance + circle_distance) / circle_distance
		smooth_vel = direction.rotated(max_rot * distance_scale) * speed

	$DirectionVisualizer.cast_to = smooth_vel# temp

	var aim_direction := global_position.direction_to(target.global_position)
	if hand_pivot.global_transform.x.distance_to(aim_direction) <= shoot_margin:
# warning-ignore:return_value_discarded
		activate_item()



func _on_WallDetector_body_entered(_body: Node) -> void:
	circle_dir = -circle_dir
