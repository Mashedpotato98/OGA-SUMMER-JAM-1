class_name Level
extends Node2D


# So that the map seed is separate from the game seed.
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	randomize()
