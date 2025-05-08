class_name InventoryItem extends Button


#region Members
#region Variables
var item := ""
var ammo := 1:
	set(value):
		ammo = value
		text = str(ammo)
#endregion

@onready var cool_down: ProgressBar = $CoolDown
#endregion


#region Functions
func _ready() -> void:
	Inventory.current_item_switched.connect(_on_Inventory_current_item_switched)


func start_cool_down(duration: float) -> void:
	cool_down.value = 1.0
	create_tween().tween_property(cool_down, ^"value", 0.0, duration * 0.9)


#region Events
func _on_InventoryItem_pressed() -> void:
	if not pressed:
		set_pressed_no_signal(true)

	Inventory.current_item = Inventory.items.keys().find(item)

	for inventory_item in get_tree().get_nodes_in_group(&"inventory_items"):
		if inventory_item == self:
			continue
		inventory_item.set_pressed_no_signal(false)


func _on_Inventory_current_item_switched(new_item: int) -> void:
	set_pressed_no_signal(get_index() == new_item)


func _on_InventoryItem_focus_entered() -> void:
	release_focus()
#endregion
#endregion
