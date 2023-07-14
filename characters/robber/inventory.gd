extends Node


signal money_changed(money)
signal current_item_switched(new_item)
signal items_changed(items)

const MAX_CRONIES := 2
const BRIBE_PATH := "res://characters/robber/bribe.tscn"

const DEFAULT_MONEY := 100_000

var file_path := "user://inventory"
var password := "y$NWO#6%T;51(nhsLZ*Q}yGm8,h:7T#Sa?ELupjw=5$C5j2TmTM0%.aQ:V4vZ8(sh6GLeR`CDZl~4n[AhF[0!(qF:7~[S<)5;=j,C)zJZb;mUyXKp*&@lA@W:D7j(HR0"

var items_list := {
	BRIBE_PATH: ItemInfo.new(preload("res://ui/icons/money.png"), [10_000], 0),
	"res://guns/submachine_gun/submachine_gun.tscn": ItemInfo.new(preload("res://guns/submachine_gun/submachine.png"), [5_000, 10_000, 15_000], 50),
	"res://guns/shot_gun/shot_gun.tscn": ItemInfo.new(preload("res://guns/shot_gun/shotgun.png"), [8_000, 12_000], 20),
	"res://guns/pistol/pistol.tscn": ItemInfo.new(preload("res://guns/pistol/pistol.png"), [10_000], 10),
	"res://guns/g36c/g36c.tscn": ItemInfo.new(preload("res://guns/g36c/g36c.png"), [10_000], 5),
	#"res:guns/": ItemInfo.new(preload("res://guns/uzi/uzi.png"), 10_000),
	#"res:guns/": ItemInfo.new(preload("res://guns/ak/ak.png"), 10_000),
}
var money := DEFAULT_MONEY setget _on_money_changed
var items := {} setget _on_items_set# <item_path> = <ammo>
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
		file.store_var({"money": money, "items": items, "cronies": cronies})
	else:
		OS.alert("Could not save inventory. Error code: " + str(error))

	file.close()


func _on_money_changed(value: int) -> void:
	money = value
	if money >= items_list[BRIBE_PATH].prices[0]:
		self.items[BRIBE_PATH] = 1
	elif items.has(BRIBE_PATH):
# warning-ignore:return_value_discarded
		if current_item >= items.keys().find(BRIBE_PATH):
			self.current_item -= 1
		self.items.erase(BRIBE_PATH)

	emit_signal("money_changed", money)


func _on_items_set(value: Dictionary) -> void:
	items = value
	emit_signal("items_changed", items)


func _on_current_item_set(value: int) -> void:
	current_item = wrapi(value, 0, items.size())
	emit_signal("current_item_switched", current_item)


class ItemInfo:
	var icon: Texture
	var prices: PoolIntArray
	var ammo: int


# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
	func _init(icon: Texture, prices: PoolIntArray, ammo: int) -> void:
		self.icon = icon
		self.prices = prices
		self.ammo = ammo
