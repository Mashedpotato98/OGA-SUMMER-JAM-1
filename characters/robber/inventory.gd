# TODO: Combine file loading/saving with settings.gd's loading/saving.
extends SaveManager


#region Members
#region Signals
signal money_changed(money: int)
signal current_item_switched(new_item: int)
signal items_changed(items: Dictionary)
#endregion

#region Constants
const MAX_CRONIES := 16
const BRIBE_PATH := "res://characters/robber/bribe.tscn"
const PASSWORD := "y$NWO#6%T;51(nhsLZ*Q}yGm8,h:7T#Sa?ELupjw=5$C5j2TmTM0%.aQ:V4vZ8(sh6GLeR`CDZl~4n[AhF[0!(qF:7~[S<)5;=j,C)zJZb;mUyXKp*&@lA@W:D7j(HR0"

const DEFAULT_MONEY := 5_000
const DEFAULT_ITEMS := {
	"res://guns/pistol/pistol.tscn": 100,
	BRIBE_PATH: MAX_CRONIES,
}
#endregion

#region Variables
var items_list := {
	BRIBE_PATH:
		ItemInfo.new(
			preload("res://ui/icons/money.png"),
			[500],
			0,
		),
	"res://guns/submachine_gun/submachine_gun.tscn":
		ItemInfo.new(
			preload("res://guns/submachine_gun/submachine.png"),
			[500, 1_000, 1_500],
			25,
		),
	"res://guns/shot_gun/shot_gun.tscn":
		ItemInfo.new(
			preload("res://guns/shot_gun/shotgun.png"),
			[800, 1_200],
			10,
		),
	"res://guns/pistol/pistol.tscn":
		ItemInfo.new(
			preload("res://guns/pistol/pistol.png"),
			[1_000],
			6,
		),
	"res://guns/g36c/g36c.tscn":
		ItemInfo.new(
			preload("res://guns/g36c/rail_gun_icon.png"),
			[400, 1_200, 1_400],
			3,
		),
	"res://explosives/grenade/grenade_launcher.tscn":
		ItemInfo.new(
			preload("res://explosives/grenade/grenade.png"),
			[500, 1000, 1000, 1500],
			1,
		),
	"res://explosives/molotov_cocktail/molotov_cocktail_thower.tscn":
		ItemInfo.new(
			preload("res://explosives/molotov_cocktail/molotov cocktail_icon.png"),
			[200, 500, 800],
			1,
		),
	#"res:guns/": ItemInfo.new(preload("res://guns/uzi/uzi.png"), 1_000),
	#"res:guns/": ItemInfo.new(preload("res://guns/ak/ak.png"), 1_000),
}
var first_raid := true
var money := DEFAULT_MONEY:
	set(value):
		money = value
		update_bribe_ammo()
		money_changed.emit(money)
var items := DEFAULT_ITEMS.duplicate():
	set(value):
		items = value
		items_changed.emit(items)
var current_item := 0:
	set(value):
		current_item = wrapi(value, 0, items.size())
		current_item_switched.emit(current_item)
var cronies := []:
	set(value):
		cronies = value
		update_bribe_ammo()
#endregion
#endregion


#region Functions
#region Overrides
func _ready() -> void:
	data = {"money": money, "items": items, "cronies": cronies, "first_raid": first_raid}
	load_file()


func load_file(password := PASSWORD) -> void:
	super(password)
	items = data.items
	cronies = data.cronies
	first_raid = data.first_raid
	money = data.money


func save_file(password := PASSWORD) -> void:
	data = {"money": money, "items": items, "cronies": cronies, "first_raid": first_raid}
	super(password)
#endregion


#region Regular
func set_item_ammo(item: String, ammo: int, relative := true) -> void:
	if relative:
		items[item] += ammo
	else:
		items[item] = ammo

	if items[item] <= 0:
		# Remove item.
		if current_item >= items.keys().find(item):
			current_item -= 1
		items.erase(item)

	items = items


func update_bribe_ammo() -> void:
	var bribe_price: int = items_list[BRIBE_PATH].prices[0]
	var crony_count := cronies.size()
	@warning_ignore("integer_division")
	set_item_ammo(BRIBE_PATH, mini(MAX_CRONIES - crony_count, money / bribe_price), false)
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
