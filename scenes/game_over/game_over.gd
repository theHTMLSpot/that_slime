extends Node2D





func _on_back_to_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
