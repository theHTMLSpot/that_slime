extends Node2D

var level_paths = Global.level_paths
var current_level = Global.current_level


	
func _On_UI_Play_Pressed() -> void:
	get_tree().change_scene_to_file(level_paths[current_level])


func _On_UI_Settings_Pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings/Settings.tscn")

func _On_UI_Quit_Pressed() -> void:
	get_tree().quit() #Quit Game
