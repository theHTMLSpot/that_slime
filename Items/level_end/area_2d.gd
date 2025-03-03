extends Area2D

@onready var level_paths = Global.level_paths  # Get level paths from the global script

@export var is_unlocked: bool
@export var name_of_key_needed: String  # The name of the key required to unlock the level

func _on_body_entered(body: Node2D) -> void:
	if body == Global.player:
		if is_unlocked:
			# Remove player from the current level and move to the next level
			body.get_parent().remove_child(body)  # Detach player
			Global.current_level += 1  # Move to the next level
			print(Global.current_level)
			Global.notifacation_message = "You completed the level. GOOD JOB!"  # Show the notification
			get_tree().change_scene_to_file(level_paths[Global.current_level])  # Change scene
		elif Global.player_inventory.has(name_of_key_needed) and not is_unlocked:  # Check if the player has the required key
			is_unlocked = true  # Unlock the level if key is found
			Global.notifacation_message = "The level is now unlocked!"  # Show a message when the level unlocks
			Global.remove_item(name_of_key_needed)
		elif not is_unlocked:
			Global.notifacation_message = "The door is locked find the key to get through"
