class_name WinScreen
extends Screen


func _init() -> void:
	Inventory.first_raid = false
	Inventory.save_inventory()


func _on_ShopButton_pressed() -> void:
	change_scene("res://ui/screens/shop.tscn")


func _on_QuitButton_pressed() -> void:
	get_tree().quit()
