class_name Shop
extends Control


export var min_items := 5
export var max_items := 15
export var items: Array = [
	ItemInfo.new(preload("res://pickups/ammo_pickup.png"), 1000, "res://guns/pistol/pistol.png"),

]

onready var tabs: TabContainer = $Tabs
onready var shop: VBoxContainer = tabs.get_node("Shop")
onready var money: Label = shop.get_node("TopBar/Money")
onready var dressing_room: Control = tabs.get_node("Dressing Room")


class ItemInfo:
	var icon: Texture
	var price: int
	var scene: String


# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
	func _init(icon: Texture, price: int, scene: String) -> void:
		self.icon = icon
		self.price = price
		self.scene = scene


func _ready() -> void:
	fill_shop()
	set_money(Inventory.money)
# warning-ignore:return_value_discarded
	Inventory.connect("money_changed", self, "set_money")


# warning-ignore:shadowed_variable
func set_money(money: int) -> void:
	self.money.text = str(money)


func fill_shop() -> void:
	for i in rand_range(min_items, max_items):
		add_item()


func add_item() -> void:
	pass
