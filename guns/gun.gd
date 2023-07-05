# Even if there is ammo, might not to have loading system.
# Perhaps handle input for guns on gun.gd so that you can hold for submachine gun, but click for sniper.
class_name Gun
extends Node2D


export var BULLET: PackedScene = null
export var spread := 0.0
export var flip := true
var cooling := false

onready var sprite: Sprite = $Sprite
onready var cool_down: Timer = $CoolDown
onready var barrel: Position2D = $Barrel
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	spread = deg2rad(spread)
	if not flip:
		set_process(false)


func _process(_delta: float) -> void:
	level_sprite()


func level_sprite() -> void:
	var flipped := global_transform.x.x < 0.0
	sprite.flip_v = flipped
	var sprite_y := abs(sprite.position.y)
	sprite.position.y = -sprite_y if flipped else sprite_y


func activate() -> bool:
	if cooling:
		return false
	add_bullet()
	start_cool_down()
	animation_player.play("Shoot")
	return true


func add_bullet() -> void:
	var bullet: Bullet = BULLET.instance()
	bullet.attack_type = owner.type
	bullet.direction = global_transform.x.rotated(rand_range(-spread, spread))
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = barrel.global_position


func start_cool_down() -> void:
	cooling = true
	cool_down.start()


func _on_CoolDown_timeout() -> void:
	cooling = false


func _on_DetectionZone_body_entered(body: Node) -> void:
	pass # Replace with function body.
