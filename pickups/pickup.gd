class_name Pickup extends Area2D


#region Members
@onready var sound_effect: AudioStreamPlayer = $SoundEffect
@onready var collision_shape: CollisionShape2D = $CollisionShape3D
#endregion


#region Functions
func _collect(_body: Node) -> void:
	sound_effect.play()
	hide()
	collision_shape.set_deferred("disabled", true)


#region Events
func _on_Pickup_body_entered(body: Node) -> void:
	if body is Robber:
		_collect(body)


func _on_SoundEffect_finished() -> void:
	queue_free()
#endregion
#endregion
