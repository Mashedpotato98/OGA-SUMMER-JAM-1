class_name Bullet
extends Area2D


export var speed := 128.0
export var dmg := 1
export var HIT_EFFECT: PackedScene = null

var attack_type := ""
var direction := Vector2()


func _ready() -> void:
	set_as_toplevel(true)


func _physics_process(delta: float) -> void:
	# This might go through hit boxes if slow frame rate / too fast speed.
	# In that case, use RayCast to detect wether it skipped anything.
	# perhaps only activate RayCast when it is moved over a certian amount within one frame.
	translate(direction * speed * delta)


func _hit() -> void:
	if HIT_EFFECT != null:
		var hit_effect: Node2D = HIT_EFFECT.instance()
		get_parent().add_child(hit_effect)
		hit_effect.global_position = global_position

	queue_free()


func _on_Bullet_area_entered(area: Area2D) -> void:
	if area.owner.type == attack_type:
		return
	area.take_dmg(global_position, dmg)
	_hit()


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()


func _on_Bullet_body_entered(_body: Node) -> void:
	_hit()
