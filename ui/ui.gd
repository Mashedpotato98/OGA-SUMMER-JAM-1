class_name UI
extends CanvasLayer


onready var health_bar: Control = $HealthBar
onready var health_bar_bg: NinePatchRect = health_bar.get_node("BG")
onready var health_bar_fill: TextureRect = health_bar.get_node("Fill")

onready var counters: GridContainer = $Counters
onready var money_counter: Label = counters.get_node("MoneyCounter")
onready var ammo_counter: Label = counters.get_node("AmmoCounter")
onready var seed_num: LineEdit = $SeedHUD/SeedNum


func _ready() -> void:
# warning-ignore:return_value_discarded
	Inventory.connect("money_changed", self, "set_money")
# warning-ignore:return_value_discarded
	Inventory.connect("ammo_changed", self, "set_ammo")


func set_max_hp(max_hp: int) -> void:
	health_bar_bg.rect_size.x = max_hp * 8.0 + 16.0


func set_hp(hp: int) -> void:
	health_bar_fill.rect_size.x = hp * 8.0


func set_money(money: int) -> void:
	money_counter.text = "$" + str(money)


func set_ammo(ammo: int) -> void:
	ammo_counter.text = str(ammo)


# warning-ignore:shadowed_variable
func set_seed(seed_num: int) -> void:
	self.seed_num.text = str(seed_num)
