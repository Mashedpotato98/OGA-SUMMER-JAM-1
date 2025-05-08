class_name HitBox extends Area2D


#region Members
signal dmg_taken(from: Vector2, amount: int)

@export var sensitivity := 1.0

#region Onready
@onready var collision_shape: CollisionShape2D = $CollisionShape3D
@onready var immunity_duration: Timer = $ImmunityDuration
#endregion
#endregion


#region Functions
#region Regular
func take_dmg(from: Vector2, amount := 1) -> void:
	start_immunity()
	dmg_taken.emit(from, int(amount * sensitivity))


func start_immunity(duration := immunity_duration.wait_time) -> void:
	collision_shape.set_deferred(&"disabled", true)
	immunity_duration.start(duration)
#endregion


func _on_ImmunityDuration_timeout() -> void:
	collision_shape.set_deferred(&"disabled", false)
#endregion
