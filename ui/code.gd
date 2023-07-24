class_name Code
extends PanelContainer


const VAULT_DIRECTION := preload("res://ui/buttons/vault_direction.tscn")

onready var directions: HBoxContainer = $Directions


func init_directions(amount: int) -> void:
	for i in amount:
		directions.add_child(VAULT_DIRECTION.instance())


func set_directions_array(directions_array: Array) -> void:
	for i in directions_array.size():
		var vault_direction: VaultDirection
		if directions.get_child_count() - 1 < i:
			vault_direction = VAULT_DIRECTION.instance()
			directions.add_child(vault_direction)
		else:
			vault_direction = directions.get_child(i)

		vault_direction.set_direction(directions_array[i])


func clear_directions() -> void:
	for vault_direction in directions.get_children():
		vault_direction.queue_free()


func get_direction_count() -> int:
	return directions.get_child_count()


func set_direction(index: int, direction) -> void:
	directions.get_child(index).set_direction(direction)


func focus(index: int) -> void:
	directions.get_child(index).grab_focus()


func release_focus() -> void:
	for vault_direction in directions.get_children():
		vault_direction.release_focus()
