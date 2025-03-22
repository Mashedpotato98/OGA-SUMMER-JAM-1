class_name Shop extends Screen


#region Members
const BUY_BUTTON := preload("res://ui/buttons/buy_button.tscn")

@export var min_items := 5
@export var max_items := 15

@onready var title: Label = $Title
@onready var done_button: Button = $DoneButton
@onready var item_lists: VBoxContainer = $ItemLists
@onready var items: GridContainer = %Items
@onready var money: Label = %Money
@onready var inventory: HBoxContainer = %Inventory
#endregion


#region Functions
func _ready() -> void:
	super()

	done_button.grab_focus()
	fill_shop()
	set_money(Inventory.money)
	Inventory.money_changed.connect(set_money)


#region Regular
func set_money(money: int) -> void:
	self.money.text = "$" + str(money)


func fill_shop() -> void:
	randomize()
	for i in randf_range(min_items, max_items):
		add_item()
	items.get_child(0).activate_button.grab_focus()


func add_item() -> void:
	items.add_child(BUY_BUTTON.instantiate())
#endregion


func _on_DoneButton_pressed() -> void:
#	if Inventory.first_raid:
#		change_scene("res://levels/level_1.tscn")#%s.tscn" % str(randi() % Level.LEVEL_VARIATIONS))
#	else:
	Inventory.save_inventory()
	change_scene_to_file("res://ui/screens/main_menu.tscn")
#endregion
