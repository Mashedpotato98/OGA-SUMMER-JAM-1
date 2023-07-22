class_name Code
extends PanelContainer


const VAULT_DIRECTION := preload("res://ui/buttons/vault_direction.tscn")

onready var directions: HBoxContainer = $Directions


func init_directions(amount: int) -> void:
	for i in amount:
		directions.add_child(VAULT_DIRECTION.instance())


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
