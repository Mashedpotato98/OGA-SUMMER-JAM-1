class_name RedDetector
extends Area2D


export var dmg := 1

var detecting := true setget _on_detecting_set

onready var sprite: Sprite = $Sprite
onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _on_detecting_set(value: bool) -> void:
	detecting = value

	sprite.visible = detecting
	collision_shape.set_deferred("disabled", not detecting)


func _on_Timer_timeout() -> void:
	self.detecting = not detecting


func _on_red_detector_area_entered(area: HitBox) -> void:
	area.take_dmg(global_position, dmg)
