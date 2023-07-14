class_name MoneyPickup
extends Pickup


export var amount := 1_000


func _collect(_body: Node) -> void:
	Inventory.money += amount
	queue_free()
