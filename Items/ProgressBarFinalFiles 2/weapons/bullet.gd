extends Area2D

@export var speed := 1500.0
@export var damage := 20.0
@export var lifespan :=  1.5
var velocity = Vector2()
var player_velocity

@onready var bullet_trail = $BulletTrail

func _ready():
	var direction = global_transform.x
	rotation = direction.angle()
	velocity = direction * speed + player_velocity
	await get_tree().create_timer(lifespan).timeout
	queue_free()


func _physics_process(delta):
	position += velocity * delta


func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

