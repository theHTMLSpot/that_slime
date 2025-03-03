extends TextureProgressBar

var player: CharacterBody2D  # Reference to player node

func _ready():
	player = Global.player
func _process(delta):
	if player != null:
		if player.is_sprinting:
			var target_value = ((player.sprint_time_left / player.sprint_duration) * 10)  # Decreasing effect
			value = target_value
		elif not player.can_sprint:
			var target_value = 10 -((player.sprint_cooldown_left / player.sprint_cooldown) * 10)  # Filling effect
			value =target_value # Smooth increase
	
