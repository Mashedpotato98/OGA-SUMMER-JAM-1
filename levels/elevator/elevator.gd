class_name Elevator
extends Area2D


#region Members
signal robber_entered

#region Onready
@onready var door: AnimatedSprite2D = $Door
@onready var needle: Sprite2D = $Needle
#endregion
#endregion


#region Functions
func _on_Elevator_body_entered(body: Node) -> void:
	if body is Robber:
		robber_entered.emit()


func _on_OpenZone_body_entered(_body: Node) -> void:
	if door.frame == 0:
		door.play(&"open")
#endregion
