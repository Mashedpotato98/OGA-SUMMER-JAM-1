class_name WinScreen extends Screen


@onready var shop_button: Button = %ShopButton


#region Functions
#region Overrides
func _init() -> void:
	Inventory.first_raid = false
	Inventory.save_inventory()


func _ready() -> void:
	super()
	shop_button.grab_focus()
#endregion


#region Events
func _on_ShopButton_pressed() -> void:
	change_scene_to_file("res://ui/screens/shop.tscn")


func _on_QuitButton_pressed() -> void:
	get_tree().quit()
#endregion
#endregion
