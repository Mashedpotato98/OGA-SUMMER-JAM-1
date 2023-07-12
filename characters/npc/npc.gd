class_name NPC
extends Character


export var skins := []
export var desired_distance := 4.0

onready var target := global_position
onready var wall_detector: RayCast2D = $WallDetector


func _ready() -> void:
	._ready()

	skins.shuffle()
	sprite.texture = skins[0]


func _physics_process(delta: float) -> void:
	._physics_process(delta)

	if global_position.distance_to(target) < desired_distance:
		wall_detector.enabled = true
		var wander_points := get_tree().get_nodes_in_group("wander_points")
		wander_points.shuffle()

		for wander_point in wander_points:
			var wander_pos: Vector2 = wander_point.global_position
			wall_detector.cast_to = to_local(wander_pos)
			wall_detector.force_raycast_update()
			if not wall_detector.is_colliding():
				target = wander_pos
				break

		wall_detector.enabled = false

	smooth_vel = global_position.direction_to(target) * speed
