extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body == Global.player:
		Global.player.has_dash_power_up = true
		queue_free()
