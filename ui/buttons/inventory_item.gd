class_name InventoryItem
extends Button


var item := ""
var ammo := 1 setget _on_ammo_set

onready var cool_down: ProgressBar = $CoolDown


func _ready() -> void:
# warning-ignore:return_value_discarded
	Inventory.connect("current_item_switched", self, "_on_Inventory_current_item_switched")


func start_cool_down(duration: float) -> void:
	cool_down.value = 1.0
# warning-ignore:return_value_discarded
	create_tween().tween_property(cool_down, "value", 0.0, duration * 0.9)


func _on_ammo_set(value: int) -> void:
	ammo = value
	text = "X" + str(ammo)


func _on_InventoryItem_pressed() -> void:
	if not pressed:
		set_pressed_no_signal(true)

	Inventory.current_item = Inventory.items.keys().find(item)

	for inventory_item in get_tree().get_nodes_in_group("inventory_items"):
		if inventory_item == self:
			continue
		inventory_item.set_pressed_no_signal(false)


func _on_Inventory_current_item_switched(new_item: int) -> void:
	set_pressed_no_signal(get_index() == new_item)


func _on_InventoryItem_focus_entered() -> void:
	release_focus()
