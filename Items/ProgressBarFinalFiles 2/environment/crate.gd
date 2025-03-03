extends StaticBody2D


@export var max_health = 200.0

@onready var current_health = max_health


func take_damage(damage):
	current_health -= damage
	var healthbar_progress = (current_health/max_health) * 100
	$HealthBar.set_value(healthbar_progress)

	if current_health <= 0:
		queue_free()
