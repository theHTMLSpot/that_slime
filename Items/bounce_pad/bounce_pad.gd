extends Area2D

@export var show_grab: bool = false
@export var show_release: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body == Global.player or body == Global.slime and body.following_player == true:
		body.velocity.y = -1000

func _process(_delta: float) -> void:
	if $grab:
		$grab.visible = show_grab
	if $release:
		$release.visible = show_release
