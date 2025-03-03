extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body == Global.player:
		body.current_health = 0
	elif body == Global.slime:
		body.global_position = Global.current_checkpoint_pos
