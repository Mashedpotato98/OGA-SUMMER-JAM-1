extends KinematicBody2D

var speed = 100
onready var Anim = $AnimationTree
var velocity = Vector2.ZERO
var timer = 1220
var can_dash = true
var slot = 0

#can interact with ___
var can_interact_submachine = false
var can_interact_shotgun = false
var can_interact_g36c = false

#name of different guns to delete them later
var submachine = null
var shotgun = null
var g36c = null

var submachine_preload = preload("res://Scenes/Submachine gun.tscn")
var shotgun_preload = preload("res://Scenes/Shotgun.tscn")

var holding = 0
#1 = submachine
#2 = shotgun
#3 = g36c


#state machine
enum {
	MOVE,
	HIT,
	DASH,
	DEATH
}
var state = MOVE

func _physics_process(delta):
	#state machine
	match state:
		MOVE:
			move_state()
		HIT:
			hit_state()
		DASH:
			dash_state()
		DEATH:
			death_state()
	
	#misc
	_move_and_other_misc()
	switch_state()

#different states
func move_state():
	velocity.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	velocity.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")

	velocity = velocity.normalized()
	
	if velocity == Vector2.ZERO:
		Anim.get("parameters/playback").travel("Idle")
	else:
		Anim.get("parameters/playback").travel("Walk")
		Anim.set("parameters/Idle/blend_position",velocity)
		Anim.set("parameters/Walk/blend_position",velocity)

func hit_state():
	pass

func dash_state():
	Anim.get("parameters/playback").travel("Idle")
	speed = 400

func death_state():
	pass

func _move_and_other_misc():
	move_and_slide(velocity*speed)



	#picking up stuf
	if Input.is_action_just_pressed("Interact") and can_interact_submachine == true and slot == 0:#picking up for submachine gun

		submachine.get_parent().queue_free()

		yield(get_tree().create_timer(0.1),"timeout")
		var submachine_ins = submachine_preload.instance()
		add_child(submachine_ins)

		submachine_ins.state = 2
		
		can_interact_submachine = false
		submachine = null
		
		slot += 1
		holding = 1#1 for submachine

	if Input.is_action_just_pressed("Interact") and can_interact_shotgun == true and slot == 0 :#picking up for shotgun

		shotgun.get_parent().queue_free()

		yield(get_tree().create_timer(0.1),"timeout")
		var shotgun_ins = shotgun_preload.instance()
		add_child(shotgun_ins)

		shotgun_ins.state = 2
		can_interact_shotgun = false
		shotgun = null
		slot += 1
		holding = 2#2 for shotgun
		

#drop weapon
	if Input.is_action_just_pressed("Drop") and holding == 1:
		get_node("Submachine gun").state = 1
		remove_child(get_node("Submachine gun"))
		slot -= 1
		holding = 0

	if Input.is_action_just_pressed("Drop") and holding == 2:
		get_node("Shotgun").state = 1
		remove_child(get_node("Shotgun"))
		slot -= 1
		holding = 0


#change state
func switch_state():
	if Input.is_action_just_pressed("Dash,Roll") and can_dash == true:
		state = DASH
		$Dash.start(0.3)
		can_dash = false


func _on_Dash_timeout():
	state = MOVE
	speed = 100
	can_dash = true

func _on_Hitbox_body_entered(body):
	$Hitbox.damage()

func _on_InteractionArea_area_entered(area):
	#detect which weapon it is
	if area.is_in_group("Shotgun"):
		can_interact_shotgun = true
		shotgun = area

	if area.is_in_group("Submachine"):
		can_interact_submachine = true
		submachine = area

func _on_InteractionArea_area_exited(area):
	submachine = null
	shotgun = null
	g36c = null
	can_interact_g36c = false
	can_interact_shotgun = false
	can_interact_submachine = false
