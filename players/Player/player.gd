extends CharacterBody2D

# Constants
const GRAVITY: float = 980.0
const DEFAULT_SPEED: float = 300.0
const SPRINT_SPEED: float = 500.0
const JUMP_VELOCITY: float = -500.0
const SPRINT_JUMP_VELOCITY: float = -600.0
const ACCELERATION: float = 10.0
const FRICTION: float = 20.0
const COYOTE_TIME: float = 0.1
const JUMP_BUFFER_TIME: float = 0.15  # Buffer time for jump input
const GRAB_DIST: int = 10

# Movement variables
var speed: float = DEFAULT_SPEED
var is_sprinting: bool = false
var is_dashing: bool = false
var can_double_jump: bool = false
var attacking: bool = false
var coyote_timer = 0.0
var is_jumping = false
var jump_buffer_timer = 0.0  # Stores jump buffer time left
var can_dash: bool = true
var can_sprint: bool = true
var can_attack: bool = true

# Cooldowns & Timers
@export var attack_cooldown: float = 0.1
@export var sprint_duration: float = 10.0
@export var sprint_cooldown: float = 10.0
@export var dash_cooldown: float = 15.0
@export var dash_power: float = 2000.0
@export var dash_time: float = 0.2 # Dash duration
@export var sprint_time_left: float = 0.0
@export var sprint_cooldown_left: float = 0.0
@export var dash_cooldown_left: float = 0.0

# Power-ups
@export var has_double_jump_power_up: bool = false
@export var has_dash_power_up: bool:
	set(value):
		has_dash_power_up = value
		on_power_up_update(1)

# Health variables
const MAX_HEALTH: int = 100
@export var current_health: int = 100

func on_power_up_update(index: int):
	if index == 1:
		can_dash = has_dash_power_up

func _ready() -> void:		
	
	if self != Global.player:
		print("This is not the player!")
		return  # Exit the function early
	
	if Global.player == null:
		Global.player = self
		print(Global.player)
	else:
		print("player var filled ", Global.player)
	
	
		
	
	if has_dash_power_up:
		can_dash = true
	else:
		can_dash = false
	
	if has_double_jump_power_up:
		can_double_jump = true
	else:
		can_double_jump = false

func play_async_anim(name: String):
	$AnimatedSprite2D.play(name)
	await $AnimatedSprite2D.animation_finished

func damage_player(amount: int):
	current_health -= amount
	play_async_anim("hurt")
	
# Sprint Handling
func start_sprint_cooldown():
	can_sprint = false
	sprint_cooldown_left = sprint_cooldown
	var timer = Timer.new()
	add_child(timer)
	timer.start(sprint_cooldown)
	await timer.timeout  # Wait until the cooldown is over
	sprint_cooldown_left = 0
	can_sprint = true

# Sprint Timer
func sprint_timer():
	if can_sprint:  # Only sprint if sprinting is allowed
		is_sprinting = true
		speed = SPRINT_SPEED
		sprint_time_left = sprint_duration
		var sprint_timer = Timer.new()
		add_child(sprint_timer)
		sprint_timer.start(sprint_duration)
		await sprint_timer.timeout  # Wait until sprint duration is over
		sprint_time_left = 0
		is_sprinting = false  # Reset sprinting state when done
		speed = DEFAULT_SPEED
		start_sprint_cooldown()

# Dash Handling
func dash():
	if can_dash:
		$dash.play()
		is_dashing = true
		var direction = Input.get_axis("left", "right")
		var dash_dir = direction if direction != 0 else ($AnimatedSprite2D.flip_h and -1 or 1)
		
		velocity.x = dash_power * dash_dir
		var dash_timer = Timer.new()
		add_child(dash_timer)
		dash_timer.start(dash_time)
		await dash_timer.timeout  # Wait for dash duration
		velocity.x = 0
		is_dashing = false
		start_dash_cooldown()

func start_dash_cooldown():
	dash_cooldown_left = dash_cooldown
	can_dash = false
	var dash_cooldown_timer = Timer.new()
	add_child(dash_cooldown_timer)
	dash_cooldown_timer.start(dash_cooldown)
	await dash_cooldown_timer.timeout  # Wait until cooldown is over
	dash_cooldown_left = 0
	can_dash = has_dash_power_up

# Power-up Collection
func collect_power_up():
	var power_ups_in_play = get_tree().get_nodes_in_group("power_ups")
	for power_up in power_ups_in_play:
		if global_position.distance_to(power_up.global_position) < GRAB_DIST and power_up.has_method("pickup"):
			print("pick up")
			
			if power_up.name == "double_jump":
				can_double_jump = true
			elif power_up.name == "dash":
				can_dash = true

# Attack Handling with Cooldown
func attack():
	if can_attack:
		attacking = true
		can_attack = false
		play_async_anim("attack")

		# Check for enemies within range once
		for enemy in get_tree().get_nodes_in_group("enemy"):
			if global_position.distance_to(enemy.global_position) < 100:
				if enemy.has_method("take_damage"):
					enemy.take_damage(50)
					print("Attacking enemy:", enemy.name)
		attacking = false  # Reset attacking state after attack animation
		
		var attack_timer = Timer.new()
		add_child(attack_timer)
		attack_timer.start(attack_cooldown)
		await attack_timer.timeout
		can_attack = true


func _process(delta: float) -> void:
	if not is_instance_valid(self) or current_health <= 0:
		return
		
	if is_sprinting:
		pass
		
	if self != Global.player:
		print("This is not the player!")
		return  # Exit the function early
	

	
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		coyote_timer -= delta  # Reduce coyote time
		jump_buffer_timer -= delta  # Reduce jump buffer time
	else:
		is_jumping = false
		coyote_timer = COYOTE_TIME  # Reset coyote timer on landing
		
		# ✅ Check for jump buffer
		if jump_buffer_timer > 0:
			velocity.y = SPRINT_JUMP_VELOCITY if is_sprinting else JUMP_VELOCITY
			$jump.play()
			is_jumping = true
			jump_buffer_timer = 0  # Reset buffer

		# ✅ Reset double jump when touching the ground
		can_double_jump = has_double_jump_power_up

	# Handle jumping
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_timer > 0:  # ✅ Grounded or within coyote time
			velocity.y = SPRINT_JUMP_VELOCITY if is_sprinting else JUMP_VELOCITY
			$jump.play()
			is_jumping = true
			coyote_timer = 0  # Prevent multiple jumps from coyote time
		elif can_double_jump:  # ✅ Allow double jump once
			velocity.y = SPRINT_JUMP_VELOCITY if is_sprinting else JUMP_VELOCITY
			can_double_jump = false  # ❗ Disable double jump after using it
			$jump.play()
		else:
			# ✅ Store jump press in buffer if not able to jump yet
			jump_buffer_timer = JUMP_BUFFER_TIME

		play_async_anim("jump")

	elif Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5  # Reduce upward momentum if jump is released early

	# Get movement direction
	var direction := Input.get_axis("left", "right")

	# Dash input
	if Input.is_action_just_pressed("dash") and can_dash and direction != 0:
		dash()

	# Attack input with cooldown
	if Input.is_action_just_pressed("attack"):
		attack()
	
	if Input.is_action_just_pressed("sprint") and can_sprint and not is_sprinting:
		sprint_timer()  # Start sprinting when pressed
	elif not Input.is_action_pressed("sprint") and is_sprinting:  
		# Stop sprinting immediately if the player stops pressing the sprint button
		is_sprinting = false
		speed = DEFAULT_SPEED

	# Normal movement with acceleration and friction
	if not is_dashing:
		if direction:
			play_async_anim("walk")
			velocity.x = move_toward(velocity.x, direction * speed, ACCELERATION)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION)
			
			# Play idle animation when not moving
			if is_on_floor() and not Input.is_action_pressed("attack") and not is_jumping and not is_dashing and not is_sprinting:
				play_async_anim("idle")    

	# Flip sprite
	if direction != 0:
		$AnimatedSprite2D.flip_h = direction < 0
		$walk.play()
	else:
		$walk.stop()

	move_and_slide()



	
