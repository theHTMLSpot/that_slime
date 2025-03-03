extends CharacterBody2D

const JUMP_POWER = -500
const ACCELERATION = 800.0
const FRICTION = 600.0
const GRAVITY = 980.0
const grab_distance = 200

var Player: CharacterBody2D
var RayCast: Node2D

@export var target: Vector2
var speed: float = 400.0  
var reached_target: bool = false
var grabbed_object: Node2D
var following_player: bool = true


func jump():
	if is_on_floor():  # Only jump if on the ground
		velocity.y = JUMP_POWER
	
func grab(object: Node2D):
	object.reparent(self)
	grabbed_object = object
	object.show_grab = false
	object.show_release = true
	
func release(object: Node2D):
	
	object.reparent(get_tree().current_scene)  
	grabbed_object = null
	object.show_release = false	
	object.show_grab = false

func _ready() -> void:
	Player = Global.player
	target = Vector2(self.global_position.x , 0)  
	RayCast = $RayCast2D
	Global.slime = self

func _process(_delta: float) -> void:
	$AnimatedSprite2D.play("anim")
	
	Global.slime = self

	
	if RayCast.is_colliding():
		var collider = RayCast.get_collider()
		if collider:
			if collider.is_in_group("ground") and not reached_target:
				jump()

	var items_in_range = get_tree().get_nodes_in_group("items")
	for item in items_in_range:
		if global_position.distance_to(item.global_position) <= grab_distance:
			
				# Toggle between grab and release based on whether the item is grabbed
			item.show_grab = grabbed_object == null  # Show grab if nothing is grabbed
			item.show_release = grabbed_object != null  # Show release if an item is grabbed

			# Grab the item if it's pressed and nothing is grabbed
			if Input.is_action_just_pressed("grab") and grabbed_object == null :
				grab(item)

			# Release the item if it's pressed and an item is grabbed
			elif not grabbed_object == null and Input.is_action_just_pressed("release"):
				release(grabbed_object)  # Release the current grabbed object

	if not following_player:
		if self.global_position.distance_to(target) < 10:
			reached_target = true
		else:
			reached_target = false
	else:
		if self.global_position.distance_to(target) < 200:
			reached_target = true
		else:
			reached_target = false
		
		

	if reached_target:
		# Apply friction when stopping
		velocity.x = move_toward(velocity.x, 0, FRICTION * _delta)
		velocity.y = move_toward(velocity.y, 0, FRICTION * _delta)

	if Input.is_action_just_pressed("set_slime_target"):  
		target = get_global_mouse_position()
		following_player =false
	
		
	elif Input.is_action_just_pressed("return_to_player"):
		following_player = not following_player
	
	if following_player:
		target = Global.player_position
	

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta  

	# Movement logic
	if not reached_target:
		var direction = (target - global_position).normalized()

		# Accelerate towards the target
		velocity.x = move_toward(velocity.x, direction.x * speed, ACCELERATION * delta)

		if is_on_floor():
			velocity.y = move_toward(velocity.y, direction.y * speed, ACCELERATION * delta)

		# Flip sprite based on movement direction
		$AnimatedSprite2D.scale.x = 3 if direction.x > 0 else -3

	# Apply friction when slowing down
	if reached_target:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		velocity.y = move_toward(velocity.y, 0, FRICTION * delta)

	# Move character
	move_and_slide()
