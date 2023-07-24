class_name UI
extends CanvasLayer


const CODE := preload("res://ui/code.tscn")

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
onready var code_icon: TextureRect = $CodeIcon

onready var vault_menu: ColorRect = $VaultMenu
onready var vault_panel: PanelContainer = vault_menu.get_node("Panel")
onready var list: VBoxContainer = vault_panel.get_node("List")
onready var code_edit: Code = list.get_node("CodeEdit")
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
	if code.size() > vault.code_length:
		return

	if event.is_action_pressed("turn_right"):
		add_dir_to_code(true)
	elif event.is_action_pressed("turn_left"):
		add_dir_to_code(false)


func add_dir_to_code(direction: bool) -> void:
	self.code.append(direction)
	_on_code_set(code)

	if code.size() >= vault.code_length:
		if vault.is_code_valid(code):
			hide_vault_menu()
		else:
			yield(shake_vault_panel(), "completed")
		self.code = []


func shake_vault_panel() -> void:
	yield(get_tree(), "idle_frame") # Not sure what this does or if it's necessary; just copied it from yield docs.

	var shakes := 10
	var distance := 8.0
	var duration := 0.05
	var start_pos := vault_panel.rect_position.x

	for i in shakes:
		var direction := float(bool(i % 2 == 0)) * 2.0 - 1.0
		var final_pos := start_pos if i >= shakes - 1 else start_pos + distance * direction

		var tween := create_tween()
# warning-ignore:return_value_discarded
		tween.tween_property(vault_panel, "rect_position:x", final_pos, duration)
		yield(tween, "finished")


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
	code_edit.clear_directions()

	emit_signal("vault_menu_closed")


static func reparent(node: Node, new_parent: Node) -> void:
	var old_parent := node.get_parent()
	old_parent.remove_child(node)
	new_parent.add_child(node)


func _on_code_set(value: Array) -> void:
	code = value

	for i in code_edit.get_direction_count():
		var direction = null if code.size() - 1 < i else code[i]
		code_edit.set_direction(i, direction)

	if code.size() < code_edit.get_direction_count():
		code_edit.focus(0 if code.size() <= 0 else code.size())
	else:
		code_edit.release_focus()


func _on_Robber_cool_down_started(item: String, duration: float) -> void:
	yield(VisualServer, "frame_post_draw")
	var inventory_item: InventoryItem = inventory.get_child(Inventory.items.keys().find(item))
	if is_instance_valid(inventory_item):
		inventory_item.start_cool_down(duration)


# warning-ignore:shadowed_variable
func _on_Vault_activated(vault: Vault) -> void:
	self.vault = vault

	code_edit.init_directions(vault.code_length)
	_on_code_set(code)

	vault_menu.show()
	cancel_button.grab_focus()


func _on_CancelButton_pressed() -> void:
	hide_vault_menu()


# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func _on_Robber_code_grabbed(code: Array, from: Vector2) -> void:
	var code_instance: Code = CODE.instance()
	get_parent().add_child(code_instance)
	code_instance.set_directions_array(code)
	code_instance.rect_position = from
	code_instance.rect_scale = Vector2.ZERO

	var anim_duration := 1.0
	var start_pos := code_instance.rect_position
	# Bad code, but couldn't think of any other solution to CanvasLayer not moveing.
	reparent(code_icon, get_parent())
	var final_pos := code_icon.get_canvas_transform().affine_inverse() * code_icon.rect_position
	reparent(code_icon, self)

	var half_pos := start_pos.linear_interpolate(final_pos, 0.5)

	var tween := create_tween()
	tween.tween_property(code_instance, "rect_position", half_pos, anim_duration / 2.0
# warning-ignore:return_value_discarded
			).set_ease(Tween.EASE_OUT)
	create_tween().tween_property(code_instance, "rect_scale", Vector2.ONE * 0.5,
# warning-ignore:return_value_discarded
			anim_duration / 2.0).set_ease(Tween.EASE_OUT)

	yield(tween, "finished")

	var tween_2 := create_tween()
	tween_2.tween_property(code_instance, "rect_position", final_pos,
# warning-ignore:return_value_discarded
			anim_duration / 2.0).set_ease(Tween.EASE_IN)
	create_tween().tween_property(code_instance, "rect_scale", Vector2.ZERO, anim_duration / 2.0
# warning-ignore:return_value_discarded
			).set_ease(Tween.EASE_IN)

	yield(tween_2, "finished")
	code_icon.show()
	code_instance.queue_free()
