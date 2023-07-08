class_name NoShootZone
extends Area2D


var mouse_intersecting := false


func _on_NoShootZone_mouse_entered() -> void:
	mouse_intersecting = true


func _on_NoShootZone_mouse_exited() -> void:
	mouse_intersecting = false
