class_name SubmachineGun extends Gun


#dfunc activate() -> bool:
	#if super():
		#owner.shove(-owner.hand_pivot.global_transform.x * owner.kickback, owner.kickback_time)
		#return true
	#return false

	# NO RECOIL, YOU GODDAM SKIBIDI
