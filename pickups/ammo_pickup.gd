class_name AmmoPickup
extends Pickup


func _collect(body: Node) -> void:
	var type: String = (body as Robber).item.filename
	if type == Inventory.BRIBE_PATH:
		return

	Inventory.items[type] += int(ceil(Inventory.items_list[type].ammo / 2.0))
	._collect(body)
