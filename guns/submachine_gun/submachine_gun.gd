class_name SubmachineGun
extends Gun


func activate() -> bool:
	if .activate():
		owner.shove(-owner.hand_pivot.global_transform.x * owner.kickback, owner.kickback_time)
		return true
	return false
