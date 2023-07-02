extends Node2D

export var bull = preload("res://Scenes/Bullet.tscn")
var can_fire = true

var state = 1

func _ready():
	set_as_toplevel(true)

func _process(delta):

	#shooting state
	if state == 2:
		if Input.is_action_pressed("Shoot") and can_fire == true:
			rotation_degrees += rand_range(1,10)
			var bull_ins = bull.instance()
			bull_ins.rotation = rotation
			bull_ins.global_position = $Position2D.global_position
			get_parent().add_child(bull_ins)
			can_fire = false
			yield(get_tree().create_timer(0.1),"timeout")
			can_fire = true
		position = get_parent().position
		look_at(get_global_mouse_position())
	if state == 1:
		pass
