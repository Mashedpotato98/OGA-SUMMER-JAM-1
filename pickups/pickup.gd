class_name Pickup
extends Area2D


func _collect(_body: Node) -> void:
	queue_free()


func _on_Pickup_body_entered(body: Node) -> void:
	if body is Robber:
		_collect(body)
