class_name LoseScreen
extends Screen


func _init() -> void:
	Inventory.money = Inventory.DEFAULT_MONEY
	Inventory.current_item = 0
	Inventory.items = {}
	Inventory.cronies = []
	Inventory.save_inventory()
