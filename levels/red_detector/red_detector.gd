class_name RedDetector
extends Area2D


var detecting := true setget _on_detecting_set

onready var sprite: Sprite = $Sprite
onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _on_detecting_set(value: bool) -> void:
	detecting = value
	monitorable = true
	monitoring = false

	sprite.visible = detecting
	collision_shape.set_deferred("disabled", not detecting)

func _on_Timer_timeout() -> void:
	self.detecting = not detecting
	monitorable = false
	monitoring = false
