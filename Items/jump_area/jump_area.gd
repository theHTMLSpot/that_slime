extends Area2D






func _on_body_entered(body: Node2D) -> void:
	if body == Global.slime:
		body.velocity.y  = -1000
