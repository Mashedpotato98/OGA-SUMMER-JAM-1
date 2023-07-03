class_name Turret
extends StaticBody2D


export var turn_speed := 5.0
export var shoot_margin := 0.2
export var hp := 3 setget _on_hp_set

var robber
var shooting := false

onready var gun: Gun = $Gun
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _physics_process(delta: float) -> void:
	if robber == null:
		return

	var direction := global_position.direction_to(robber.global_position)
	global_rotation = lerp_angle(global_rotation, direction.angle(), turn_speed * delta)

	# Might could use dot product; for now just using matrix.
	if transform.x.distance_to(direction) <= shoot_margin and not shooting:
		shooting = true
		play_random()




func play_random() -> void:
	var animation = null
	var rand_num := randf()
	if rand_num <= 0.1:
		animation = "Wait"
	elif rand_num <= 0.5:
		animation = "RapidFire"
	else:
		animation = "Fire"

#	var animations := animation_player.get_animation_list()
#	var animation := animations[rand_range(0, animations.size())]
	animation_player.play(animation)


func _on_hp_set(value: int) -> void:
	hp = value
	if hp <= 0:
		queue_free()# For now.


# warning-ignore:shadowed_variable
func _on_DetectionZone_robber_entered(robber: Robber) -> void:
	self.robber = robber


func _on_DetectionZone_robber_exited() -> void:
	robber = null


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	shooting = false


func _on_HitBox_dmg_taken(_attacker: Node2D, amount: int) -> void:
	self.hp -= amount
