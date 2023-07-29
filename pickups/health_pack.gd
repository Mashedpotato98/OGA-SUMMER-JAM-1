class_name HealthPickup
extends Pickup

export var health_amount = 1

func _collect(_body: Node) -> void:
	if Robber.hp < 3:
		Robber.hp += health_amount
	queue_free()
