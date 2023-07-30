class_name MoneyPickup
extends Pickup


export var amount := 100


func _collect(body: Node) -> void:
	Inventory.money += amount
	._collect(body)
