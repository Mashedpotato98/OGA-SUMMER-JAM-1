class_name ItemPickup
extends Area2D


export var ITEM: PackedScene = null


func _on_ItemPickup_body_entered(body: Node) -> void:
	body.add_item(ITEM)
	queue_free()
