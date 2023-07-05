extends Node


signal money_changed(money)

const MAX_CRONIES := 2

var file_path := "user://inventory"
var password := "y$NWO#6%T;51(nhsLZ*Q}yGm8,h:7T#Sa?ELupjw=5$C5j2TmTM0%.aQ:V4vZ8(sh6GLeR`CDZl~4n[AhF[0!(qF:7~[S<)5;=j,C)zJZb;mUyXKp*&@lA@W:D7j(HR0"

var money := 0 setget _on_money_changed
var items := {}# <item> = <amount>
var cronies := []# only store cronie gun filepath. The gun being in the array signifies the cronie's existance.


func _ready() -> void:
	load_items()


func load_items() -> void:
	var file := File.new()
	if file.file_exists(file_path):
		var error := file.open_encrypted_with_pass(file_path, File.READ, password)
		if error == OK:
			var inventory: Dictionary = file.get_var()
			money = inventory.money
			items = inventory.items
			cronies = inventory.cronies
		else:
			OS.alert("Could not save inventory. Error code: " + str(error))
	else:
		save_items()

	file.close()


func save_items() -> void:
	var file := File.new()
	var error := file.open_encrypted_with_pass(file_path, File.WRITE, password)
	if error == OK:
		file.store_var({"money": money, "items": items, "cronies": cronies})
	else:
		OS.alert("Could not save inventory. Error code: " + str(error))

	file.close()


func _on_money_changed(value: int) -> void:
	money = value
	emit_signal("money_changed", money)
