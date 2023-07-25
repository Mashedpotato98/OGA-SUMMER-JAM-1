class_name GrenadeLauncher
extends Gun


func _ready() -> void:
	._ready()
	cooling = false
	cool_down.stop()
