class_name UI
extends CanvasLayer


signal vault_menu_closed

const INVENTORY_ITEM := preload("res://ui/buttons/inventory_item.tscn")
const VAULT_DIRECTION := preload("res://ui/buttons/vault_direction.tscn")

var vault: Vault = null
var code := [] setget _on_code_set

onready var health_bar: Control = $HealthBar
onready var health_bar_bg: NinePatchRect = health_bar.get_node("BG")
onready var health_bar_fill: TextureRect = health_bar.get_node("Fill")

onready var seed_hud: HBoxContainer = $SeedHUD
onready var seed_num: LineEdit = seed_hud.get_node("SeedNum")
onready var inventory: HBoxContainer = $Inventory
onready var money_counter: Label = $MoneyHUD/MoneyCounter

onready var vault_menu: ColorRect = $VaultMenu
onready var list: VBoxContainer = vault_menu.get_node("Menu/List")
onready var arrows: HBoxContainer = list.get_node("Arrows")
onready var cancel_button: Button = list.get_node("CancelButton")


func _ready() -> void:
# warning-ignore:return_value_discarded
	Inventory.connect("money_changed", self, "set_money")
# warning-ignore:return_value_discarded
	Inventory.connect("items_changed", self, "set_items")

	set_money(Inventory.money)
	set_items(Inventory.items)


func _input(event: InputEvent) -> void:
	if vault == null:
		return

	if event.is_action_pressed("right"):
		add_dir_to_code(true)
	elif event.is_action_pressed("left"):
		add_dir_to_code(false)


func add_dir_to_code(direction: bool) -> void:
	self.code.append(direction)
	_on_code_set(code)

	if code.size() >= vault.code_length:
		if vault.is_code_valid(code):
			hide_vault_menu()
		else:
			pass
		self.code = []


func set_max_hp(max_hp: int) -> void:
	health_bar_bg.rect_size.x = max_hp * 8.0 + 16.0


func set_hp(hp: int) -> void:
	health_bar_fill.rect_size.x = hp * 8.0


func set_money(money: int) -> void:
	money_counter.text = "$" + str(money)


func set_items(items: Dictionary) -> void:
	for inventory_item in inventory.get_children():
		inventory_item.queue_free()
	for item_path in items:
		var inventory_item: InventoryItem = INVENTORY_ITEM.instance()
		inventory.add_child(inventory_item)
		inventory_item.item = item_path
		inventory_item.icon = Inventory.items_list[item_path].icon
		inventory_item.ammo = items[item_path]


# warning-ignore:shadowed_variable
func set_seed(seed_num: int) -> void:
	self.seed_num.text = str(seed_num)


func hide_vault_menu() -> void:
	vault = null
	vault_menu.hide()
	self.code = []

	for vault_direction in arrows.get_children():
		vault_direction.queue_free()

	emit_signal("vault_menu_closed")


func _on_code_set(value: Array) -> void:
	code = value

	for i in arrows.get_child_count():
		var vault_direction := arrows.get_child(i) as VaultDirection
		var direction = null if code.size() - 1 < i else code[i]
		vault_direction.set_direction(direction)

	if code.size() < arrows.get_child_count():
		arrows.get_child(0 if code.size() <= 0 else code.size()).grab_focus()
	else:
		arrows.get_children()[-1].release_focus()


func _on_Robber_cool_down_started(item: String, duration: float) -> void:
	yield(VisualServer, "frame_post_draw")
	var inventory_item: InventoryItem = inventory.get_child(Inventory.items.keys().find(item))
	if is_instance_valid(inventory_item):
		inventory_item.start_cool_down(duration)


# warning-ignore:shadowed_variable
func _on_Vault_activated(vault: Vault) -> void:
	self.vault = vault

	for i in vault.code_length:
		arrows.add_child(VAULT_DIRECTION.instance())
	_on_code_set(code)

	cancel_button.grab_focus()
	vault_menu.show()


func _on_CancelButton_pressed() -> void:
	hide_vault_menu()
