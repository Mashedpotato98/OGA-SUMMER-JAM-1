class_name Pickup
extends Area2D


onready var sound_effect: AudioStreamPlayer = $SoundEffect
onready var collision_shape: CollisionShape2D = $CollisionShape


func _collect(_body: Node) -> void:
	sound_effect.play()
	hide()
	collision_shape.set_deferred("disabled", true)


func _on_Pickup_body_entered(body: Node) -> void:
	if body is Robber:
		_collect(body)


func _on_SoundEffect_finished() -> void:
	queue_free()
