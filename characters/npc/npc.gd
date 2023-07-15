class_name NPC
extends Character


export var skins := []

var panicking := false

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


func _on_PanicZone_saw(_what: Node) -> void:
	panicking = true
	smooth_vel = (Vector2.RIGHT * speed).rotated(rand_range(PI, -PI))
	wall_bounce_collision_shape.set_deferred("disabled", false)
	panic_zone.get_node("CollisionShape2D").set_deferred("disabled", true)


func _on_WallBounce_body_entered(_body: Node) -> void:
	var deg := -TAU / 16.0
	smooth_vel = -smooth_vel.rotated(rand_range(deg, deg))
