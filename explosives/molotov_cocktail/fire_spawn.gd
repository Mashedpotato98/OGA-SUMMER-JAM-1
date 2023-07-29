class_name FireSpawn
extends CollisionShape2D


export var min_life_time := 3.0
export var max_life_time := 6.0

onready var tween := create_tween()
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	var life_time := rand_range(min_life_time, max_life_time)
	yield(get_tree().create_timer(life_time), "timeout")
	animation_player.play("Fade")


func tween_pos(pos: Vector2) -> void:
# warning-ignore:return_value_discarded
	tween.tween_property(self, "position", pos, 0.2)
