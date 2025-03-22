# Even if there is ammo, might not need to have loading system.
# Perhaps handle input for guns on gun.gd so that you can hold for submachine gun, but click for sniper.
class_name Gun extends Node2D


#region Members
#region Export
@export var BULLET: PackedScene = null
@export var spread := 0.0
@export var flip := true
@export var distance := 104.0
#endregion

var cooling := true

#region Onready
@onready var sprite: Sprite2D = $Sprite2D
@onready var cool_down: Timer = $CoolDown
@onready var barrel: Marker2D = $Barrel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound
#endregion
#endregion


#region Functions
#region Overrides
func _ready() -> void:
	spread = deg_to_rad(spread)
	if not flip:
		set_process(false)


func _process(_delta: float) -> void:
	level_sprite()
#endregion


#region Regular
func level_sprite() -> void:
	var flipped := global_transform.x.x < 0.0
	sprite.flip_v = flipped
	var sprite_y := absf(sprite.position.y)
	sprite.position.y = -sprite_y if flipped else sprite_y


func activate() -> bool:
	if cooling:
		return false
	shoot_sound.play()
	add_bullet()
	start_cool_down()
	animation_player.play(&"Shoot")
	return true


func add_bullet() -> void:
	var bullet: Bullet = BULLET.instantiate()
	bullet.attack_type = owner.type
	bullet.direction = global_transform.x.rotated(randf_range(-spread, spread))
	bullet.distance = distance
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = barrel.global_position
	bullet._post_translation()


func start_cool_down() -> void:
	cooling = true
	cool_down.start()
#endregion


func _on_CoolDown_timeout() -> void:
	cooling = false
#endregion
