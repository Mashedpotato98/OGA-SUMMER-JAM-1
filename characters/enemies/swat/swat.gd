class_name Swat
extends Enemy


export var dmg := 1
export var swat_cool_down := 1.0

onready var swat_zone_shape: CollisionShape2D = $SwatZone/CollisionShape2D
onready var animation_tree: AnimationTree = $AnimationTree
onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")


func _process(_delta: float) -> void:
	# Using _process() instead of _physics_process() because animation isn't physics related.
	animate()


# Copied from cop.gd. Should be a parent function.
# But does it make sense for enemy.gd to have animation?
func animate() -> void:
	var anim_name := ""
	if smooth_vel.length() >= speed:
		anim_name = "Run"
	elif smooth_vel.length() > 0.0:
		anim_name = "Walk"
	else:
		anim_name = "Idle"

	animation_tree.set("parameters/%s/blend_position" % anim_name, smooth_vel)
	playback.travel(anim_name)


func _on_SwatZone_area_entered(area: Area2D) -> void:
	if area.owner.type == type or area.owner.type == "all":
		return
	area.take_dmg(global_position, dmg)

	animation_tree.set("parameters/Attack/blend_position", smooth_vel)
	playback.travel("Attack")

	swat_zone_shape.set_deferred("disabled", true)
	yield(get_tree().create_timer(swat_cool_down), "timeout")
	swat_zone_shape.set_deferred("disabled", false)
