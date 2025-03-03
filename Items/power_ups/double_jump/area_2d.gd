extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body == Global.player:
		Global.player.has_double_jump_power_up = true
		queue_free()
