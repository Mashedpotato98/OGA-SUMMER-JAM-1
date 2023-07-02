extends Node2D

export var bull = preload("res://Scenes/Bullet.tscn")
var can_fire = true
var state = 1

func _ready():
	set_as_toplevel(true)

func _process(delta):

	if state == 1:
		pass

	if state == 2:
		if Input.is_action_pressed("Shoot") and can_fire == true:
			var bull_ins1 = bull.instance()
			bull_ins1.rotation = rotation
			bull_ins1.global_position = $Position2D.global_position
			get_parent().add_child(bull_ins1)
			can_fire = false

			var bull_ins2 = bull.instance()
			bull_ins2.rotation = rotation
			bull_ins2.global_position = $Position2D2.global_position
			get_parent().add_child(bull_ins2)
			can_fire = false

			var bull_ins3 = bull.instance()
			bull_ins3.rotation = rotation
			bull_ins3.global_position = $Position2D3.global_position
			get_parent().add_child(bull_ins3)
			can_fire = false

			bull_ins1.spd = 1000
			bull_ins2.spd = 1000
			bull_ins3.spd = 1000

			yield(get_tree().create_timer(0.1),"timeout")
			bull_ins1.queue_free()
			bull_ins2.queue_free()
			bull_ins3.queue_free()
			yield(get_tree().create_timer(1),"timeout")
			can_fire = true
		look_at(get_global_mouse_position())
		position = get_parent().position
