extends Node


#region Members
#region Signals
signal money_changed(money: int)
signal current_item_switched(new_item: int)
signal items_changed(items: Dictionary)
#endregion

#region Constants
const MAX_CRONIES := 16
const BRIBE_PATH := "res://characters/robber/bribe.tscn"

const DEFAULT_MONEY := 5_000
const DEFAULT_ITEMS := {
	"res://guns/pistol/pistol.tscn": 100,
	BRIBE_PATH: MAX_CRONIES,
}
#endregion

#region Variables
var path := "user://godot_4/"
var file := "inventory"
var file_path := path + file
var password := "y$NWO#6%T;51(nhsLZ*Q}yGm8,h:7T#Sa?ELupjw=5$C5j2TmTM0%.aQ:V4vZ8(sh6GLeR`CDZl~4n[AhF[0!(qF:7~[S<)5;=j,C)zJZb;mUyXKp*&@lA@W:D7j(HR0"

var items_list := {
	BRIBE_PATH: ItemInfo.new(preload("res://ui/icons/money.png"), [500], 0),
	"res://guns/submachine_gun/submachine_gun.tscn": ItemInfo.new(preload("res://guns/submachine_gun/submachine.png"), [500, 1_000, 1_500], 25),
	"res://guns/shot_gun/shot_gun.tscn": ItemInfo.new(preload("res://guns/shot_gun/shotgun.png"), [800, 1_200], 10),
	"res://guns/pistol/pistol.tscn": ItemInfo.new(preload("res://guns/pistol/pistol.png"), [1_000], 6),
	"res://guns/g36c/g36c.tscn": ItemInfo.new(preload("res://guns/g36c/rail_gun_icon.png"), [400, 1_200, 1_400], 3),
	"res://explosives/grenade/grenade_launcher.tscn": ItemInfo.new(preload("res://explosives/grenade/grenade.png"), [500, 1000, 1000, 1500], 1),
	"res://explosives/molotov_cocktail/molotov_cocktail_thower.tscn": ItemInfo.new(preload("res://explosives/molotov_cocktail/molotov cocktail_icon.png"), [200, 500, 800], 1),
	#"res:guns/": ItemInfo.new(preload("res://guns/uzi/uzi.png"), 1_000),
	#"res:guns/": ItemInfo.new(preload("res://guns/ak/ak.png"), 1_000),
}
var money := DEFAULT_MONEY: set = _on_money_changed
var items := DEFAULT_ITEMS.duplicate(): set = _on_items_set
var current_item := 0: set = _on_current_item_set
var cronies := []: set = _on_cronies_set
var first_raid := true
#endregion
#endregion


#region Functions
func _ready() -> void:
	load_inventory()
	_on_money_changed(money)


#region Regular
func load_inventory() -> void:
	if FileAccess.file_exists(file_path):
		var file := FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, password)
		var error := FileAccess.get_open_error()
		if error == OK:
			var inventory: Dictionary = file.get_var()
			items = inventory.items
			self.cronies = inventory.cronies
			first_raid = inventory.first_raid
			self.money = inventory.money
		else:
			OS.alert("Could not load inventory.\nError: " + error_string(error))
	else:
		save_inventory()


func save_inventory() -> void:
	if not DirAccess.dir_exists_absolute(path):
		@warning_ignore("confusable_local_declaration")
		var error := DirAccess.make_dir_recursive_absolute(path)
		if error != OK:
			OS.alert("Could not create save directory.\nError: " + error_string(error))
			return

	var file := FileAccess.open_encrypted_with_pass(file_path, FileAccess.WRITE, password)
	var error := FileAccess.get_open_error()
	if error == OK:
		var data := {"money": money, "items": items, "cronies": cronies, "first_raid": first_raid}
		file.store_var(data)
	else:
		OS.alert("Could not save inventory.\nError: " + error_string(error))


func set_item_ammo(item: String, ammo: int, relative := true) -> void:
	if relative:
		self.items[item] += ammo
	else:
		self.items[item] = ammo

	if items[item] <= 0:
		remove_item(item)

	_on_items_set(items)


func remove_item(item: String) -> void:
	if current_item >= items.keys().find(item):
		self.current_item -= 1
	self.items.erase(item)


func check_bribe_count() -> void:
	var bribe_price: int = items_list[BRIBE_PATH].prices[0]
	var crony_count := cronies.size()
	@warning_ignore("integer_division")
	set_item_ammo(BRIBE_PATH, mini(MAX_CRONIES - crony_count, money / bribe_price), false)
#endregion


#region Events
func _on_cronies_set(value: Array) -> void:
	cronies = value
	check_bribe_count()


func _on_money_changed(value: int) -> void:
	money = value
	check_bribe_count()
	money_changed.emit(money)


func _on_items_set(value: Dictionary) -> void:
	items = value
	items_changed.emit(items)


func _on_current_item_set(value: int) -> void:
	current_item = wrapi(value, 0, items.size())
	current_item_switched.emit(current_item)
#endregion
#endregion

class ItemInfo:
#region Members
	var icon: Texture2D
	var prices: PackedInt32Array
	var ammo: int
#endregion


	func _init(icon: Texture2D, prices: PackedInt32Array, ammo: int) -> void:
		self.icon = icon
		self.prices = prices
		self.ammo = ammo
