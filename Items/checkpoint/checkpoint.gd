extends Area2D

var is_flipped := false

func _on_body_entered(body: Node2D) -> void:
	if body == Global.player: 
		Global.current_checkpoint_pos = global_position
		if is_flipped:
			return
		$AnimatedSprite2D.flip_h = not is_flipped
		is_flipped = true
		Global.notifacation_message = "checkpoint reached"
