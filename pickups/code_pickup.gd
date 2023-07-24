class_name CodePickup
extends Pickup


var code := []


func _collect(body: Node) -> void:
	body.set_code(code, global_position)
	queue_free()
