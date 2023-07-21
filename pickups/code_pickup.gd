class_name CodePickup
extends Pickup


func _collect(body: Node) -> void:
	queue_free()
