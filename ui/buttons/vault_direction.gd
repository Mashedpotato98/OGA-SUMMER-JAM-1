class_name VaultDirection extends TextureRect


#region Members
#region Constants
const LEFT := preload("res://ui/icons/turn_left.png")
const RIGHT := preload("res://ui/icons/turn_right.png")
#endregion

#region Onready
@onready var arrow: TextureRect = $Arrow
@onready var focus_texture: TextureRect = $Focus
#endregion
#endregion


#region Functions
@warning_ignore("untyped_declaration")
func set_direction(direction) -> void:
	arrow.texture = direction if direction == null else (RIGHT if direction else LEFT)


func focus() -> void:
	focus_texture.show()
	for vault_direction in get_tree().get_nodes_in_group(&"vault_directions"):
		if vault_direction == self:
			continue
		vault_direction.remove_focus()


func remove_focus() -> void:
	focus_texture.hide()
#endregion
#endregion
