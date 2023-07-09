class_name UI
extends CanvasLayer


const INVENTORY_ITEM := preload("res://ui/buttons/inventory_item.tscn")
const ITEM_ICONS := {
	"res://characters/robber/bribe.tscn": preload("res://ui/icons/money.png"),
	"res://guns/pistol/pistol.tscn": preload("res://guns/pistol/pistol.png"),
	"res://guns/g36c/g36c.tscn": preload("res://guns/g36c/g36c.png"),
	"res://guns/shot_gun/shot_gun.tscn": preload("res://guns/shot_gun/shotgun.png"),
	"res://guns/submachine_gun/submachine_gun.tscn": preload("res://guns/submachine_gun/submachine.png"),
}

onready var health_bar: Control = $HealthBar
onready var health_bar_bg: NinePatchRect = health_bar.get_node("BG")
onready var health_bar_fill: TextureRect = health_bar.get_node("Fill")

onready var counters: GridContainer = $Counters
onready var money_counter: Label = counters.get_node("MoneyCounter")
onready var ammo_counter: Label = counters.get_node("AmmoCounter")
onready var seed_hud: HBoxContainer = $SeedHUD
onready var seed_num: LineEdit = seed_hud.get_node("SeedNum")
onready var inventory: HBoxContainer = $Inventory


func _ready() -> void:
# warning-ignore:return_value_discarded
	Inventory.connect("money_changed", self, "set_money")
# warning-ignore:return_value_discarded
	Inventory.connect("ammo_changed", self, "set_ammo")
# warning-ignore:return_value_discarded
	Inventory.connect("items_changed", self, "set_items")

	set_money(Inventory.money)
	set_ammo(Inventory.ammo)
	set_items(Inventory.items)


func set_max_hp(max_hp: int) -> void:
	health_bar_bg.rect_size.x = max_hp * 8.0 + 16.0


func set_hp(hp: int) -> void:
	health_bar_fill.rect_size.x = hp * 8.0


func set_money(money: int) -> void:
	money_counter.text = "$" + str(money)


func set_ammo(ammo: int) -> void:
	ammo_counter.text = str(ammo)


func set_items(items: Dictionary) -> void:
	for inventory_item in inventory.get_children():
		inventory_item.queue_free()
	for item in items:
		var inventory_item: InventoryItem = INVENTORY_ITEM.instance()
		inventory.add_child(inventory_item)
		inventory_item.item = item
		inventory_item.icon = ITEM_ICONS[item]
		inventory_item.count = items[item]


# warning-ignore:shadowed_variable
func set_seed(seed_num: int) -> void:
	self.seed_num.text = str(seed_num)
