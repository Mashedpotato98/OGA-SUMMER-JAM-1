class_name Swat
extends Enemy


export var dmg := 1


func _on_SwatZone_area_entered(area: Area2D) -> void:
	if area.owner.type == type or area.owner.type == "all":
		return
	area.take_dmg(global_position, dmg)
