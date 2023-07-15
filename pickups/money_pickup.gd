class_name MoneyPickup
extends Pickup


export var amount := 100


func _collect(_body: Node) -> void:
	Inventory.money += amount
	queue_free()
