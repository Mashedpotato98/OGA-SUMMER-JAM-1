extends Node


signal money_changed(money)
signal ammo_changed(ammo)
signal current_item_switched(new_item)
signal items_changed(items)

const MAX_CRONIES := 2
const BRIBE_COST := 10_000
const BRIBE_PATH := "res://characters/robber/bribe.tscn"

const DEFAULT_MONEY := 100_000
const DEFAULT_AMMO := 100

var file_path := "user://inventory"
var password := "y$NWO#6%T;51(nhsLZ*Q}yGm8,h:7T#Sa?ELupjw=5$C5j2TmTM0%.aQ:V4vZ8(sh6GLeR`CDZl~4n[AhF[0!(qF:7~[S<)5;=j,C)zJZb;mUyXKp*&@lA@W:D7j(HR0"

var money := DEFAULT_MONEY setget _on_money_changed
var ammo := DEFAULT_AMMO setget _on_ammo_changed
var items := {} setget _on_items_set# <item_path> = <amount>
var current_item := 0 setget _on_current_item_set
var cronies := []# [{"type": <Enemy file path>, "weapon": <weapon path>}]


func _ready() -> void:
	load_inventory()
	_on_money_changed(money)


func load_inventory() -> void:
	var file := File.new()
	if file.file_exists(file_path):
		var error := file.open_encrypted_with_pass(file_path, File.READ, password)
		if error == OK:
			var inventory: Dictionary = file.get_var()
			self.money = inventory.money
			self.ammo = inventory.ammo
			items = inventory.items
			cronies = inventory.cronies
		else:
			OS.alert("Could not save inventory. Error code: " + str(error))
	else:
		save_inventory()

	file.close()


func save_inventory() -> void:
	var file := File.new()
	var error := file.open_encrypted_with_pass(file_path, File.WRITE, password)
	if error == OK:
		file.store_var({"money": money, "ammo": ammo, "items": items, "cronies": cronies})
	else:
		OS.alert("Could not save inventory. Error code: " + str(error))

	file.close()


func _on_money_changed(value: int) -> void:
	money = value
	if money >= BRIBE_COST:
		self.items[BRIBE_PATH] = 1
	elif items.has(BRIBE_PATH):
# warning-ignore:return_value_discarded
		if current_item >= items.keys().find(BRIBE_PATH):
			self.current_item -= 1
		self.items.erase(BRIBE_PATH)

	emit_signal("money_changed", money)


func _on_ammo_changed(value: int) -> void:
	ammo = value
	emit_signal("ammo_changed", ammo)


func _on_items_set(value: Dictionary) -> void:
	items = value
	emit_signal("items_changed", items)


func _on_current_item_set(value: int) -> void:
	current_item = wrapi(value, 0, items.size())
	emit_signal("current_item_switched", current_item)
