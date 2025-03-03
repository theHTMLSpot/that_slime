extends Node

const MAX_IVEN = 5

var player: CharacterBody2D
var player_position: Vector2 = Vector2.ZERO  # Default position (0,0)

# Dictionary inventory (Key = item_name, Value = item instance)
var player_inventory: Dictionary = {}

var player_lives: int = 5
var slime: CharacterBody2D

var notifacation_message: String = ""

var level_paths: Array[String] = ["res://scenes/levels/level_1/Level_1.tscn", "res://scenes/levels/level_2/Level_2.tscn"]
var current_level: int:
	set(value):
		current_level = clamp(value, 0, len(level_paths) - 1)

var current_checkpoint_pos: Vector2 = Vector2.ZERO

func add_item(item: Node2D):
	if not item.has_method("get_item_name"):  
		print("Error: Item does not have a name.")
		return
	
	var item_name = item.get_item_name()  # Get item name from a method
	
	if len(player_inventory) < MAX_IVEN:
		if not player_inventory.has(item_name):
			player_inventory[item_name] = item
			notifacation_message = item_name + " collected."
		else:
			notifacation_message = "Item already in inventory."
	else:
		notifacation_message = "Inventory is full."
	
	print(player_inventory)

func remove_item(item_name: String):
	if player_inventory.has(item_name):
		player_inventory.erase(item_name)  # Remove the item from the dictionary
		notifacation_message = item_name + " removed from inventory."
	else:
		notifacation_message = "Item not found in inventory"
		
	print(player_inventory)


func _process(delta: float) -> void:
	
	if player:
		player_position = player.global_position
		if player.current_health == 0:
			player.global_position = current_checkpoint_pos
			player.current_health = 100
			slime.global_position = Vector2(Global.player.global_position.x - 100, Global.player.global_position.y)
			slime.target = Global.slime.global_position
			player_lives -= 1
			if player_lives == 0:
				current_level -= 1
				get_tree().change_scene_to_file(level_paths[current_level])
				current_checkpoint_pos = Vector2.ZERO
				player_lives = 5
