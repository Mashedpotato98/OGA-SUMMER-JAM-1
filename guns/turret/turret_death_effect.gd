class_name TurretDeathEffect
extends AnimatedSprite2D


func _ready() -> void:
	play()


func _on_DeathSound_finished() -> void:
	queue_free()
