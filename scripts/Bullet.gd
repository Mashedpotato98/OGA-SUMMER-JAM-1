extends Area2D

export var spd = 2000

func _ready():
	set_as_toplevel(true)

func _process(delta):
	position += (Vector2.RIGHT*spd).rotated(rotation) * delta

func _physics_process(delta):
	yield(get_tree().create_timer(0.01),"timeout")
	set_physics_process(false)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Bullet_body_entered(body):
	queue_free()
