extends Area2D

export var health:float

func _process(delta):
	if health <= 0:
		get_parent().queue_free()

func damage():
	health -= 1
