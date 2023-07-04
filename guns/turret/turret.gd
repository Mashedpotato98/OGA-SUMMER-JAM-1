class_name Turret
extends StaticBody2D


export var turn_speed := 5.0
export var shoot_margin := 0.2
export var hp := 3 setget _on_hp_set

var robber
var shooting := false

onready var auto_aimer: AutoAimer = $AutoAimer
onready var gun: Gun = auto_aimer.get_node("Gun")
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _process(_delta: float) -> void:
	if robber == null:
		return

	var direction := global_position.direction_to(robber.global_position)
	# Might could use dot product; for now just using matrix.
	if auto_aimer.transform.x.distance_to(direction) <= shoot_margin and not shooting:
		shooting = true
		play_random()


func play_random() -> void:
	var rand_num := randf()
	if rand_num <= 0.25:
		animation_player.play("RapidFire")

		var sweep_range := TAU / 4.0
		yield(sweep(sweep_range / 2.0, 0.5), "finished")
		yield(sweep(-sweep_range, 0.5), "finished")
# warning-ignore:return_value_discarded
		sweep(sweep_range / 2.0, 0.25)
	else:
		animation_player.play("Fire")

#	var animations := animation_player.get_animation_list()
#	var animation := animations[rand_range(0, animations.size())]
#	animation_player.play(animation)


func sweep(angle: float, duration: float) -> SceneTreeTween:
	var tween := create_tween()
# warning-ignore:return_value_discarded
	tween.tween_property(auto_aimer, "transform", auto_aimer.transform.rotated(angle), duration)
	return tween


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
