class_name UI
extends CanvasLayer


const INVENTORY_ITEM := preload("res://ui/buttons/inventory_item.tscn")

onready var health_bar: Control = $HealthBar
onready var health_bar_bg: NinePatchRect = health_bar.get_node("BG")
onready var health_bar_fill: TextureRect = health_bar.get_node("Fill")

onready var money_counter: Label = $MoneyHUD/MoneyCounter

onready var seed_hud: HBoxContainer = $SeedHUD
onready var seed_num: LineEdit = seed_hud.get_node("SeedNum")
onready var inventory: HBoxContainer = $Inventory


func _ready() -> void:
# warning-ignore:return_value_discarded
	Inventory.connect("money_changed", self, "set_money")
# warning-ignore:return_value_discarded
	Inventory.connect("items_changed", self, "set_items")

	set_money(Inventory.money)
	set_items(Inventory.items)


func set_max_hp(max_hp: int) -> void:
	health_bar_bg.rect_size.x = max_hp * 8.0 + 16.0


func set_hp(hp: int) -> void:
	health_bar_fill.rect_size.x = hp * 8.0


func set_money(money: int) -> void:
	money_counter.text = "$" + str(money)


func set_items(items: Dictionary) -> void:
	for inventory_item in inventory.get_children():
		inventory_item.queue_free()
	for item_path in items:
		var inventory_item: InventoryItem = INVENTORY_ITEM.instance()
		inventory.add_child(inventory_item)
		inventory_item.item = item_path
		inventory_item.icon = Inventory.items_list[item_path].icon
		inventory_item.ammo = items[item_path]


# warning-ignore:shadowed_variable
func set_seed(seed_num: int) -> void:
	self.seed_num.text = str(seed_num)


func _on_Robber_cool_down_started(item: String, duration: float) -> void:
	yield(VisualServer, "frame_pre_draw")
	var inventory_item: InventoryItem = inventory.get_child(Inventory.items.keys().find(item))
	if is_instance_valid(inventory_item):
		inventory_item.start_cool_down(duration)
