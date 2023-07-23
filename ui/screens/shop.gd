class_name Shop
extends Screen


const BUY_BUTTON := preload("res://ui/buttons/buy_button.tscn")

export var min_items := 5
export var max_items := 15

onready var title: Label = $Title
onready var done_button: Button = $DoneButton
onready var item_lists: VBoxContainer = $ItemLists
onready var menu: VBoxContainer = item_lists.get_node("Market/Menu")
onready var items: GridContainer = menu.get_node("ScrollContainer/Items")
onready var money: Label = menu.get_node("TopBar/Money")
onready var inventory: HBoxContainer = item_lists.get_node("Inventory")


func _ready() -> void:
	._ready()

	done_button.grab_focus()
	fill_shop()
	set_money(Inventory.money)
# warning-ignore:return_value_discarded
	Inventory.connect("money_changed", self, "set_money")


# warning-ignore:shadowed_variable
func set_money(money: int) -> void:
	self.money.text = "$" + str(money)


func fill_shop() -> void:
	randomize()
	for i in rand_range(min_items, max_items):
		add_item()
	items.get_child(0).activate_button.grab_focus()


func add_item() -> void:
	items.add_child(BUY_BUTTON.instance())


func _on_DoneButton_pressed() -> void:
	if Inventory.first_raid:
		change_scene("res://levels/level_1.tscn")#%s.tscn" % str(randi() % Level.LEVEL_VARIATIONS))
	else:
		Inventory.save_inventory()
		change_scene("res://ui/screens/main_menu.tscn")
