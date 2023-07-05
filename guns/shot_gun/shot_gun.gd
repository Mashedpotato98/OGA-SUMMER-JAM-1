class_name ShotGun
extends Gun


export var bullets := 3


func activate() -> bool:
	if cooling:
		return false

	for i in bullets - 1:
		add_bullet()

# warning-ignore:return_value_discarded
	.activate()
	return true
