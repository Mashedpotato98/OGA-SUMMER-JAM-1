class_name FireSpawn extends CollisionShape2D


#region Members
#region Export
@export var min_life_time := 5.0
@export var max_life_time := 10.0
#endregion

#region Onready
@onready var tween := create_tween()
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#endregion
#endregion


#region Functions
func _ready() -> void:
	var life_time := randf_range(min_life_time, max_life_time)
	await get_tree().create_timer(life_time).timeout
	animation_player.play(&"Fade")


func tween_pos(pos: Vector2) -> void:
	tween.tween_property(self, ^"position", pos, 0.2)
#endregion
