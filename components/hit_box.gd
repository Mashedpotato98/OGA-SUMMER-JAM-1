class_name HitBox
extends Area2D


signal dmg_taken(from, amount)

export var sensitivity := 1.0

onready var collision_shape: CollisionShape2D = $CollisionShape
onready var immunity_duration: Timer = $ImmunityDuration


func take_dmg(from: Vector2, amount := 1) -> void:
	start_immunity()
	emit_signal("dmg_taken", from, int(amount * sensitivity))


func start_immunity(duration := immunity_duration.wait_time) -> void:
	collision_shape.set_deferred("disabled", true)
	immunity_duration.start(duration)


func _on_ImmunityDuration_timeout() -> void:
	collision_shape.set_deferred("disabled", false)
