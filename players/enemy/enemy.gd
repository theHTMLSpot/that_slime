extends CharacterBody2D

# Movement
const SPRINT_DURATION: int = 5
const SPRINT_COOLDOWN: int = 10
const STOPPING_DIST: int = 200
const ACCELERATION: float = 600.0  # Acceleration for movement
const FRICTION: float = 800.0      # Friction when stopping

# Attack
const ATTACK_DIST: int = 125
const TRACKING_DIST: int = 450

# Damage
const DAMAGE_DIST: int = 275

# Movement
@export var sprint_speed: int = 300
@export var jump_height: int = -550
@export var default_speed: int = 200

# Attack
@export var damage: int = 5
@export var attack_cooldown: int = 3

# Damage
@export var health: int:
	set(value):
		health = clamp(value, 0, 100)

# Variables
var is_sprinting: bool = false
var can_sprint: bool = true
var speed: int = 350
var ray_cast: RayCast2D
var following_player: bool = false

var target: Vector2
var Player: CharacterBody2D
var reached_target: bool = false
var can_attack: bool = true

func take_damage(amount):
	health -= amount

func start_sprint_cooldown():
	can_sprint = false
	await get_tree().create_timer(SPRINT_COOLDOWN).timeout
	can_sprint = true

func sprint_timer():
	is_sprinting = true
	await get_tree().create_timer(SPRINT_DURATION).timeout
	is_sprinting = false

	if can_sprint:
		await start_sprint_cooldown()

func jump():
	if is_on_floor():  # Only jump if on the floor
		velocity.y = jump_height

func attack():
	if Player and Player.has_method("damage_player"):
		can_attack = false
		Player.damage_player(damage)
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func _ready() -> void:
	
	Player = Global.player

	print(Player)
	ray_cast = $RayCast2D if $RayCast2D else null
	health = 100

func _process(delta: float) -> void:
	
	
	if ray_cast == null:
		return
	
	Player = Global.player
	if Global.player == null:
		print("error")
		return
	
	if Global.player_position == null:
		print("error")
		return
		

	target = Global.player_position
	

	if global_position.distance_to(Player.global_position) < TRACKING_DIST:
		following_player = true

		if global_position.distance_to(Player.global_position) < ATTACK_DIST and can_attack:
			attack()

		if global_position.distance_to(Player.global_position) < STOPPING_DIST:
			following_player = false

	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider and collider.is_in_group("ground"):
			jump()

	if can_sprint and not is_sprinting:
		is_sprinting = true  # Prevent multiple timers
		await sprint_timer()

	if health == 0:
		queue_free()

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += 980 * delta  

	# Adjust speed based on sprinting state
	var target_speed = sprint_speed if is_sprinting else default_speed

	# Smooth acceleration when following player
	if following_player:
		var direction = (target - global_position).normalized()
		velocity.x = move_toward(velocity.x, direction.x * target_speed, ACCELERATION * delta)

		# Allow slight vertical movement for more natural tracking
		if is_on_floor():
			velocity.y = move_toward(velocity.y, direction.y * 10, ACCELERATION * delta)

		# Flip sprite based on movement direction
		$AnimatedSprite2D.scale.x = 3 if direction.x > 0 else -3
	else:
		# Apply friction when not moving
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Move character
	move_and_slide()

func _on_kill_area_body_entered(body: Node2D) -> void:
	if body == Global.player or body == Global.slime:
		queue_free()
