class_name Fire
extends Area2D


const FIRE_SPAWN := preload("res://explosives/molotov_cocktail/fire_spawn.tscn")

export var distance := 64.0
export var flames := 50
export var dmg := 1

onready var sound_effect: AudioStreamPlayer2D = $SoundEffect


func _ready() -> void:
	for i in flames:
		spawn_flame()

	sound_effect.play()


func spawn_flame() -> void:
	var fire_spawn: FireSpawn = FIRE_SPAWN.instance()
	call_deferred("add_child", fire_spawn)
	yield(fire_spawn, "ready")
	var final_pos := (Vector2.RIGHT * rand_range(0.0, distance)).rotated(randf() * TAU)
	fire_spawn.tween_pos(final_pos)


func _on_Fire_child_exiting_tree(_node: Node) -> void:
	if get_child_count() <= 2:# Exclude default nodes & node *about* to exit tree.
		queue_free()


func _on_Timer_timeout() -> void:
	for area in get_overlapping_areas():
		if area is HitBox:
			area.take_dmg(area.global_position, dmg)
