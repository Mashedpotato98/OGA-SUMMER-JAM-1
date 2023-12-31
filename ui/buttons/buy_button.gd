class_name BuyButton
extends PanelContainer


onready var menu: VBoxContainer = $Menu
onready var icon: TextureRect = menu.get_node("Icon")
onready var price_label: Label = menu.get_node("PriceLabel")
onready var activate_button: Button = menu.get_node("ActivateButton")

onready var refund_sound: AudioStreamPlayer = $RefundSound
onready var buy_sound: AudioStreamPlayer = $BuySound

var bought := false
var item := ""
var price := 0


func _ready() -> void:
	item = Inventory.items_list.keys()[randi() % (Inventory.items_list.size() - 1) + 1]# skip bribe
	var item_info: Inventory.ItemInfo = Inventory.items_list[item]
	icon.texture = item_info.icon
	price = item_info.prices[randi() % item_info.prices.size()]
	price_label.text = "$" + str(price)

# warning-ignore:return_value_discarded
	Inventory.connect("money_changed", self, "_on_Inventory_money_changed")
	_on_Inventory_money_changed(Inventory.money)


func _on_Inventory_money_changed(money: int) -> void:
	activate_button.disabled = false if bought else money < price


func _on_ActivateButton_pressed() -> void:
	bought = not bought
	var ammo: int = Inventory.items_list[item].ammo

	if bought:
		buy_sound.play()
		activate_button.text = "Refund"
		activate_button.modulate = Color.white
		Inventory.money -= price

		if Inventory.items.has(item):
			Inventory.set_item_ammo(item, ammo)
		else:
			Inventory.set_item_ammo(item, ammo, false)
	else:
		refund_sound.play()
		activate_button.text = "Buy"
		activate_button.modulate = Color(0.0, 0.89, 0.21)
		Inventory.money += price

		Inventory.set_item_ammo(item, -ammo)
