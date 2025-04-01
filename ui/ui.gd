class_name UI extends CanvasLayer


#region Members
#region Signals
signal vault_menu_closed
signal vault_menu_opened
#endregion

#region Constants
const CODE := preload("res://ui/code.tscn")
const INVENTORY_ITEM := preload("res://ui/buttons/inventory_item.tscn")
const VAULT_DIRECTION := preload("res://ui/buttons/vault_direction.tscn")
#endregion

#region Variables
var vault: Vault = null
var code := []:
	set(value):
		code = value

		for i in code_edit.get_direction_count():
			@warning_ignore("untyped_declaration")
			var direction = null if code.size() - 1 < i else code[i]
			code_edit.set_direction(i, direction)

		if code.size() < code_edit.get_direction_count():
			code_edit.focus(0 if code.size() <= 0 else code.size())
		else:
			code_edit.release_focus()
#endregion

#region Onready
@onready var health_bar_bg: NinePatchRect = %BG
@onready var health_bar_fill: TextureRect = %Fill

@onready var seed_num: LineEdit = %SeedNum
@onready var inventory: HBoxContainer = $Inventory

@onready var money_counter: Label = %MoneyCounter
@onready var code_icon: TextureRect = $CodeIcon

@onready var vault_menu: ColorRect = $VaultMenu
@onready var wrong_sound: AudioStreamPlayer = %WrongSound
@onready var turn_sound: AudioStreamPlayer = %TurnSound
@onready var vault_panel: PanelContainer = %Panel

@onready var key_panel: PanelContainer = %KeyPanel
@onready var key_code_display: Code = %KeyCodeDisplay

@onready var code_edit: Code = %CodeEdit
@onready var cancel_button: Button = %CancelButton
#endregion
#endregion


#region Functions
#region Overrides
func _ready() -> void:
	Inventory.money_changed.connect(set_money)
	Inventory.items_changed.connect(set_items)

	set_money(Inventory.money)
	set_items(Inventory.items)


func _input(event: InputEvent) -> void:
	if vault == null:
		return
	if code.size() > vault.code_length:
		return

	if event.is_action_pressed(&"turn_right"):
		add_dir_to_code(true)
	elif event.is_action_pressed(&"turn_left"):
		add_dir_to_code(false)
#endregion


#region Regular
func add_dir_to_code(direction: bool) -> void:
	code.append(direction)
	code = code

	turn_sound.play()

	if code.size() >= vault.code_length:
		if vault.is_code_valid(code):
			hide_vault_menu()
		else:
			wrong_sound.play()
			await shake_vault_panel()
		code = []


func shake_vault_panel() -> void:
	var shakes := 10
	var distance := 8.0
	var duration := 0.05
	var start_pos := vault_panel.position.x

	for i in shakes:
		var direction := float(bool(i % 2 == 0)) * 2.0 - 1.0
		var final_pos := start_pos if i >= shakes - 1 else start_pos + distance * direction

		var tween := create_tween()
		tween.tween_property(vault_panel, ^"position:x", final_pos, duration)
		await tween.finished


func set_max_hp(max_hp: int) -> void:
	health_bar_bg.size.x = max_hp * 8.0 + 16.0


func set_hp(hp: int) -> void:
	health_bar_fill.size.x = hp * 8.0


func set_money(money: int) -> void:
	money_counter.text = "$" + str(money)


func set_items(items: Dictionary) -> void:
	for inventory_item in inventory.get_children():
		inventory_item.queue_free()
	for item_path: String in items:
		var inventory_item: InventoryItem = INVENTORY_ITEM.instantiate()
		inventory.add_child(inventory_item)
		inventory_item.item = item_path
		inventory_item.icon = Inventory.items_list[item_path].icon
		inventory_item.ammo = items[item_path]


func set_seed(seed_num: int) -> void:
	self.seed_num.text = str(seed_num)


func hide_vault_menu() -> void:
	vault = null
	vault_menu.hide()
	code = []
	code_edit.clear_directions()

	vault_menu_closed.emit()
#endregion


#region Events
func _on_Robber_cool_down_started(item: String, duration: float) -> void:
	await RenderingServer.frame_post_draw
	var inventory_item: InventoryItem = inventory.get_child(Inventory.items.keys(

	).find(item))
	inventory_item.start_cool_down(duration)


func _on_Vault_activated(vault: Vault) -> void:
	self.vault = vault

	code_edit.init_directions(vault.code_length)
	code = code

	vault_menu.show()
	cancel_button.grab_focus()
	vault_menu_opened.emit()


func _on_CancelButton_pressed() -> void:
	hide_vault_menu()


func _on_Robber_code_grabbed(code: Array, from: Vector2) -> void:
	key_panel.show()
	key_code_display.set_directions_array(code)

	var code_instance: Code = CODE.instantiate()
	get_parent().add_child(code_instance)
	code_instance.set_directions_array(code)
	code_instance.position = from
	code_instance.scale = Vector2.ZERO

	var anim_duration := 1.0
	var start_pos := code_instance.position
	# Bad code, but couldn't think of any other solution to CanvasLayer not moving.
	code_icon.reparent(get_parent())
	# Magical line copy-pasted from Reddit: MODIFY AT YOUR OWN RISK
	var final_pos := code_icon.get_canvas_transform().affine_inverse() * code_icon.position
	code_icon.reparent(self)

	var half_pos := start_pos.lerp(final_pos, 0.5)

	# Bunch'a tweening stuff
	var tween := create_tween()
	tween.tween_property(code_instance, ^"position", half_pos, anim_duration / 2.0
			).set_ease(Tween.EASE_OUT)
	create_tween().tween_property(code_instance, ^"scale", Vector2.ONE * 0.3,
			anim_duration / 2.0).set_ease(Tween.EASE_OUT)

	await tween.finished

	var tween_2 := create_tween()
	tween_2.tween_property(code_instance, ^"position", final_pos,
			anim_duration / 2.0).set_ease(Tween.EASE_IN)
	create_tween().tween_property(code_instance, ^"scale", Vector2.ZERO, anim_duration / 2.0
			).set_ease(Tween.EASE_IN)

	await tween_2.finished
	code_icon.show()
	code_instance.queue_free()
#endregion
#endregion
