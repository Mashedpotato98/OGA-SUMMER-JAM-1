class_name ShotGun extends Gun


@export var bullets := 4


func activate() -> bool:
	if cooling:
		return false

	for i in bullets - 1:
		add_bullet()

	super()
	return true
