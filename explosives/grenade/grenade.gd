class_name Grenade
extends Bullet


export var min_distance := 64.0
export var explosion_safe_margin := 8.0

var explosion_radius := Splash.new().distance

onready var enemy_detector: Area2D = $EnemyDetector
onready var enemy_detector_shape: CapsuleShape2D = enemy_detector.get_node("CollisionShape2D").shape


func _ready() -> void:
	._ready()
	enemy_detector_shape.radius = explosion_radius
	enemy_detector.rotation = direction.angle()


func _physics_process(delta: float) -> void:
	._physics_process(delta)

	var remaining_length := distance - distance_traveled
	enemy_detector_shape.height = remaining_length
	enemy_detector.position = direction * (remaining_length / 2.0)

	var average := Vector2()
	var enemies := enemy_detector.get_overlapping_bodies()
	var refining := true
	while refining and enemies.size() > 0:
		refining = false
		for enemy in enemies:
			assert(not enemy is Robber)
			average += enemy.global_position
		average /= enemies.size()
		for i in range(enemies.size() - 1, -1, -1):
			if global_position.distance_to(enemies[i].global_position) > explosion_radius \
					+ explosion_safe_margin:
				enemies.remove(i)
				refining = true

	var target_distance := direction.dot(to_local(average))
	if enemies.size() > 0 and target_distance <= 0.0 and distance_traveled >= min_distance:
# warning-ignore:return_value_discarded
		_hit()


func _hit() -> Node2D:
	var hit_effect: Node2D = ._hit()
	hit_effect.attack_type = attack_type

	return hit_effect
