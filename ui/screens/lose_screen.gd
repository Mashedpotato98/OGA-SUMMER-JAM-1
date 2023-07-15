class_name LoseScreen
extends Screen


onready var home_button: Button = $Menu/HomeButton


func _init() -> void:
	Inventory.money = Inventory.DEFAULT_MONEY
	Inventory.current_item = 0
	Inventory.items = Inventory.DEFAULT_ITEMS.duplicate()
	Inventory.cronies = []
	Inventory.first_raid = true
	Inventory.save_inventory()


func _ready() -> void:
	._ready()
	home_button.grab_focus()


func _on_HomeButton_pressed() -> void:
	change_scene("res://ui/screens/main_menu.tscn")


func _on_QuitButton_pressed() -> void:
	get_tree().quit()
