class_name InventoryItem
extends Button


var item := ""
var count := 1 setget _on_count_set


func _ready() -> void:
# warning-ignore:return_value_discarded
	Inventory.connect("current_item_switched", self, "_on_Inventory_current_item_switched")


func _on_count_set(value: int) -> void:
	count = value
	text = "X" + str(count)


func _on_InventoryItem_pressed() -> void:
	if not pressed:
		set_pressed_no_signal(true)

	Inventory.current_item = Inventory.items.keys().find(item)
	release_focus()

	for inventory_item in get_tree().get_nodes_in_group("inventory_items"):
		if inventory_item == self:
			continue
		inventory_item.set_pressed_no_signal(false)


func _on_Inventory_current_item_switched(new_item: int) -> void:
	set_pressed_no_signal(get_index() == new_item)
