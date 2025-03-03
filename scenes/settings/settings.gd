extends Node2D





func _on_UI_Back_To_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/Menu.tscn")
