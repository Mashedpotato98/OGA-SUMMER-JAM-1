class_name BuyButton extends PanelContainer


#region Members
#region Onready
@onready var icon: TextureRect = %Icon
@onready var price_label: Label = %PriceLabel
@onready var activate_button: Button = %ActivateButton

@onready var refund_sound: AudioStreamPlayer = $RefundSound
@onready var buy_sound: AudioStreamPlayer = $BuySound
#endregion

#region Variables
var bought := false
var item := ""
var price := 0
#endregion
#endregion


#region Functions
func _ready() -> void:
	item = Inventory.items_list.keys()[randi() % (Inventory.items_list.size() - 1) + 1]# skip bribe
	var item_info: Inventory.ItemInfo = Inventory.items_list[item]
	icon.texture = item_info.icon
	price = item_info.prices[randi() % item_info.prices.size()]
	price_label.text = "$" + str(price)

	Inventory.money_changed.connect(_on_Inventory_money_changed)
	_on_Inventory_money_changed(Inventory.money)


#region Events
func _on_Inventory_money_changed(money: int) -> void:
	activate_button.disabled = false if bought else money < price


func _on_ActivateButton_pressed() -> void:
	bought = not bought
	var ammo: int = Inventory.items_list[item].ammo

	if bought:
		buy_sound.play()
		activate_button.text = "Refund"
		activate_button.modulate = Color.WHITE
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
#endregion
#endregion
