class_name AmmoPickup
extends Pickup


export var amount := 10


func _collect(body: Node) -> void:
	body.ammo += amount
	queue_free()
