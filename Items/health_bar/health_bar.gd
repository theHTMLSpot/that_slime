extends TextureProgressBar


func _process(delta: float) -> void:
	var owner = get_parent()
	var target_value
	
	if "health" in owner:
		target_value = owner.health
	elif "current_health" in owner:
		target_value = owner.current_health
	
	if target_value == 100:
		visible = false
	else:
		visible = true
		value = target_value
