extends Node2D

var BULLET_SCENE = preload("res://weapons/bullet.tscn")

@export var damage := 20
@export var fire_rate := 0.12
@export var spread := 3

var can_fire = true

@onready var muzzle := $Muzzle
@onready var muzzle_flash := $Sprites/MuzzleFlash
@onready var audio_shoot := $AudioShoot
@onready var animation_player := $AnimationPlayer

func _physics_process(delta):
	if Input.is_action_pressed("fire"): 
		fire()


func fire():
	if not can_fire: return

	muzzle_flash.show()
	muzzle_flash.play()
	animation_player.play("fire")
	audio_shoot.play()
	#Spread
	muzzle.rotation = 0
	var rand_rotation = deg_to_rad(randf_range(-spread, spread))
	muzzle.rotate(rand_rotation)

	spawn_bullet()
	
	can_fire = false
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
	


func spawn_bullet():
	var instance = BULLET_SCENE.instantiate()
	var scene_root = get_node("/root/World")
	instance.global_position = muzzle.global_position
	instance.global_rotation = muzzle.global_rotation
	instance.player_velocity = get_parent().get_parent().velocity
	instance.damage = damage
	scene_root.add_child(instance)



func _on_muzzle_flash_animation_finished():
	muzzle_flash.hide()
