extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player = Global.player
	self.value = 10 - ((player.dash_cooldown_left / player.dash_cooldown) * 10 )
