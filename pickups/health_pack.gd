class_name HealthPack
extends Pickup


export var health_amount = 1


func _collect(body: Node) -> void:
	if body.hp < body.max_hp:
		body.hp += health_amount
	queue_free()
