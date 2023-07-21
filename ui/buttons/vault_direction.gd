class_name VaultDirection
extends TextureRect


const LEFT := preload("res://ui/icons/turn_left.png")
const RIGHT := preload("res://ui/icons/turn_right.png")

onready var arrow: TextureRect = $Arrow
onready var focus: TextureRect = $Focus


func set_direction(direction) -> void:
	arrow.texture = direction if direction == null else (RIGHT if direction else LEFT)


func grab_focus() -> void:
	focus.show()
	for vault_direction in get_tree().get_nodes_in_group("vault_directions"):
		if vault_direction == self:
			continue
		vault_direction.release_focus()


func release_focus() -> void:
	focus.hide()
