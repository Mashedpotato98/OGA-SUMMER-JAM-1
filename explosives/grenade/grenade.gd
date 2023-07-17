class_name Grenade
extends Bullet


func _hit() -> Node2D:
	var hit_effect: Splash = ._hit()
	hit_effect.attack_type = attack_type

	return hit_effect
