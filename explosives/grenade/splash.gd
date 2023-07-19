class_name Splash
extends Node2D


export var distance := 64.0
export var bullets := 25
export var BULLET: PackedScene

var attack_type := ""


func _ready() -> void:
	yield(VisualServer, "frame_post_draw")
	explode()


func explode() -> void:
	for i in bullets:
		var bullet: Bullet = BULLET.instance()
		bullet.direction = Vector2.RIGHT.rotated(TAU * (float(i) / bullets))
		bullet.attack_type = attack_type
		bullet.distance = distance
		bullet.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", bullet)


func _on_ExplodeSound_finished() -> void:
	queue_free()
