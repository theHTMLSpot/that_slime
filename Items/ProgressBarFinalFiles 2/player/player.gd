extends CharacterBody2D

class_name Player

@export var speed := 700
@export var acceleration := 25.0


func _ready():
	Input.set_custom_mouse_cursor(
		load("res://ui/assets/images/crosshair.png"),
		Input.CURSOR_ARROW, Vector2(16,16)
	)


func _physics_process(delta):
	move(delta)


func move(delta):
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	velocity = velocity.lerp(direction * speed, acceleration * delta)

	move_and_slide()

	# Aim (has to be after move, otherwise there's jitter)
	var mouse_position = get_global_mouse_position()
	look_at(mouse_position)

