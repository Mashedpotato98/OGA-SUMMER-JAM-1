class_name NPC
extends Character


export var skins := []
export var desired_distance := 4.0
export var walk_speed := 16

var panicking := false

onready var target := global_position
onready var wall_detector: RayCast2D = $WallDetector
onready var panic_zone: DetectionZone = $PanicZone
onready var wall_bounce_collision_shape: CollisionShape2D = $WallBounce/CollisionShape


func _ready() -> void:
	._ready()

	skins.shuffle()
	sprite.texture = skins[0]


func _physics_process(delta: float) -> void:
	._physics_process(delta)

	if not panicking:
		wander()


func wander() -> void:
	if global_position.distance_to(target) < desired_distance:
		choose_target()

	smooth_vel = global_position.direction_to(target) * walk_speed


func choose_target() -> void:
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


func _on_PanicZone_saw(_what: Node) -> void:
	panicking = true
	smooth_vel = (Vector2.RIGHT * speed).rotated(rand_range(PI, -PI))
	wall_bounce_collision_shape.set_deferred("disabled", false)
	panic_zone.get_node("CollisionShape2D").set_deferred("disabled", true)


func _on_WallBounce_body_entered(_body: Node) -> void:
	var deg := -TAU / 16.0
	smooth_vel = -smooth_vel.rotated(rand_range(deg, deg))
