class_name Fire
extends Node2D


const FIRE_SPAWN := preload("res://explosives/molotov_cocktail/fire_spawn.tscn")

export var distance := 64.0
export var flames := 50

var attack_type := ""


func _ready() -> void:
	spawn_flame()


func spawn_flame() -> void:
	pass
