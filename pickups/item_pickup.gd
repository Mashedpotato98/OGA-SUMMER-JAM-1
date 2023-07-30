class_name ItemPickup
extends Pickup


export var ITEM: PackedScene = null


func _collect(body: Node) -> void:
	body.add_item(ITEM)
	._collect(body)
