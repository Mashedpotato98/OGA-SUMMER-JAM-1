extends Node


signal money_changed(money)
signal current_item_switched(new_item)
signal items_changed(items)

const MAX_CRONIES := 4
const BRIBE_PATH := "res://characters/robber/bribe.tscn"

const DEFAULT_MONEY := 5_000
const DEFAULT_ITEMS := {
	"res://guns/pistol/pistol.tscn": 50,
	BRIBE_PATH: MAX_CRONIES,
}

var file_path := "user://inventory"
var password := "y$NWO#6%T;51(nhsLZ*Q}yGm8,h:7T#Sa?ELupjw=5$C5j2TmTM0%.aQ:V4vZ8(sh6GLeR`CDZl~4n[AhF[0!(qF:7~[S<)5;=j,C)zJZb;mUyXKp*&@lA@W:D7j(HR0"

var items_list := {
	BRIBE_PATH: ItemInfo.new(preload("res://ui/icons/money.png"), [1_000], 0),
	"res://guns/submachine_gun/submachine_gun.tscn": ItemInfo.new(preload("res://guns/submachine_gun/submachine.png"), [500, 1_000, 1_500], 25),
	"res://guns/shot_gun/shot_gun.tscn": ItemInfo.new(preload("res://guns/shot_gun/shotgun.png"), [800, 1_200], 10),
	"res://guns/pistol/pistol.tscn": ItemInfo.new(preload("res://guns/pistol/pistol.png"), [1_000], 6),
	"res://guns/g36c/g36c.tscn": ItemInfo.new(preload("res://guns/g36c/rail_gun_icon.png"), [400, 1_200, 1_400], 3),
	"res://explosives/grenade/grenade_launcher.tscn": ItemInfo.new(preload("res://explosives/grenade/grenade.png"), [100, 250, 250, 500, 500], 1),
	"res://explosives/molotov_cocktail/molotov_cocktail_thower.tscn": ItemInfo.new(preload("res://explosives/molotov_cocktail/molotov cocktail_icon.png"), [300, 500, 750], 1),
	#"res:guns/": ItemInfo.new(preload("res://guns/uzi/uzi.png"), 1_000),
	#"res:guns/": ItemInfo.new(preload("res://guns/ak/ak.png"), 1_000),
}
var money := DEFAULT_MONEY setget _on_money_changed
var items := DEFAULT_ITEMS.duplicate() setget _on_items_set# <item_path> = <ammo>
var current_item := 0 setget _on_current_item_set
var cronies := [] setget _on_cronies_set# [{"type": <Enemy file path>, "weapon": <weapon path>}]
var first_raid := true


func _ready() -> void:
	load_inventory()
	_on_money_changed(money)


func load_inventory() -> void:
	var file := File.new()
	if file.file_exists(file_path):
		var error := file.open_encrypted_with_pass(file_path, File.READ, password)
		if error == OK:
			var inventory: Dictionary = file.get_var()
			items = inventory.items
			self.cronies = inventory.cronies
			first_raid = inventory.first_raid
			self.money = inventory.money
		else:
			OS.alert("Could not save inventory. Error code: " + str(error))
	else:
		save_inventory()

	file.close()


func save_inventory() -> void:
	var file := File.new()
	var error := file.open_encrypted_with_pass(file_path, File.WRITE, password)
	if error == OK:
		var data := {"money": money, "items": items, "cronies": cronies, "first_raid": first_raid}
		file.store_var(data)
	else:
		OS.alert("Could not save inventory. Error code: " + str(error))

	file.close()


func set_item_ammo(item: String, ammo: int, relative := true) -> void:
	if relative:
		self.items[item] += ammo
	else:
		self.items[item] = ammo

	if items[item] <= 0:
		remove_item(item)

	_on_items_set(items)


func remove_item(item: String) -> void:
# warning-ignore:return_value_discarded
	if current_item >= items.keys().find(item):
		self.current_item -= 1
	self.items.erase(item)


func check_bribe_count() -> void:
	var bribe_price: int = items_list[BRIBE_PATH].prices[0]
	var crony_count := cronies.size()
# warning-ignore:narrowing_conversion
# warning-ignore:integer_division
	set_item_ammo(BRIBE_PATH, min(MAX_CRONIES - crony_count, money / bribe_price), false)


func _on_cronies_set(value: Array) -> void:
	cronies = value
	check_bribe_count()


func _on_money_changed(value: int) -> void:
	money = value
	check_bribe_count()
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
