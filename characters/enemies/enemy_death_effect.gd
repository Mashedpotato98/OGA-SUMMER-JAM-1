class_name EnemyDeathEffect
extends CPUParticles2D


export var duration := 3.0


func _ready() -> void:
	emitting = true
	yield(get_tree().create_timer(duration), "timeout")
	queue_free()
