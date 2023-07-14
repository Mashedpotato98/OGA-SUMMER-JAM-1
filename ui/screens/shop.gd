class_name Shop
extends Screen


const BUY_BUTTON := preload("res://ui/buttons/buy_button.tscn")

export var min_items := 5
export var max_items := 15

onready var tabs: TabContainer = $Tabs
onready var shop: VBoxContainer = tabs.get_node("Shop")
onready var items: GridContainer = shop.get_node("ScrollContainer/Items")
onready var money: Label = shop.get_node("TopBar/Money")
onready var dressing_room: Control = tabs.get_node("Dressing Room")


func _ready() -> void:
	._ready()

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
	items.get_child(0).activate_button.grab_focus()


func add_item() -> void:
	items.add_child(BUY_BUTTON.instance())


func _on_DoneButton_pressed() -> void:
	Inventory.save_inventory()
	change_scene("res://ui/screens/main_menu.tscn")
