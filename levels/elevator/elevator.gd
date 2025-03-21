class_name Elevator
extends Area2D


signal robber_entered

@onready var door: AnimatedSprite2D = $Door
@onready var needle: Sprite2D = $Needle


func _on_Elevator_body_entered(body: Node) -> void:
	if body is Robber:
		emit_signal("robber_entered")



func _on_OpenZone_body_entered(_body: Node) -> void:
	if door.frame == 0:
		door.play("open")
