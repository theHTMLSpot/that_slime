extends Node2D

var slime: CharacterBody2D
var health_number: Control

var checkpoint_nodes: Array[Node2D]
var current_checkpoint: int = 0
var current_checkpoint_pos: Vector2 = Vector2(339, 484)

var has_player: bool = false

func _ready() -> void:
	# Ensure Global.player is valid and persistent
	if Global.player == null:
		print("ERROR: Global.player is null! Creating a new player.")
		Global.player = preload("res://players/Player/Player.tscn").instantiate()
	
	if Global.slime == null:
		print("ERROR: Global.slime is null! Creating a new slime.")
		Global.slime = preload("res://players/Slime_helper/slime.tscn").instantiate()

	health_number = $Camera2D/health_number

	# Only add Global.player if it's not already in the scene
	if not Global.player.is_inside_tree():
		add_child(Global.player)
		Global.player.global_position = current_checkpoint_pos
		print("Player added to scene.")

	# Set slime position relative to player
	Global.slime.global_position = Vector2(Global.player.global_position.x - 100, Global.player.global_position.y)

func _process(delta: float) -> void:
	# Ensure the player exists in the scene
	if not has_player and Global.player and not Global.player.is_inside_tree():
		add_child(Global.player)
		Global.player.global_position = current_checkpoint_pos
		has_player = true
		print("Player added.")

	var target_position: Vector2

	# Determine the camera's target position
	if Input.is_action_pressed("find_slime"):
		target_position = Global.slime.global_position + Vector2(0, 10)
	else:
		target_position = Global.player.global_position + Vector2(0, 10)  # Fixed reference

	# Smoothly move the camera towards the target
	$Camera2D.global_position = lerp($Camera2D.global_position, target_position, 5 * delta)

	# Return to menu if needed
	if Input.is_action_just_pressed("back_to_menu"):
		get_tree().change_scene_to_file("res://scenes/menu/Menu.tscn")

	# Respawn player at checkpoint if health is 0
	if Global.player.current_health == 0:
		Global.player.global_position = current_checkpoint_pos
		Global.player.current_health = 100
		Global.slime.global_position = Vector2(Global.player.global_position.x - 100, Global.player.global_position.y)
		Global.slime.target = Global.slime.global_position
