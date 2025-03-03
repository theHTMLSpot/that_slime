extends Area2D
var collected := false
@export var item_name: String

var show_grab: bool = false
var show_release: bool = false


func _process(_delta: float) -> void:
	if $grab:
		$grab.visible = show_grab
	if $release:
		$release.visible = show_release

func _on_body_entered(body: Node2D) -> void:
	if body == Global.player and not collected:
		Global.add_item(self)  # Adds the item to the player's inventory
		print(self)
		
		self.reparent(Global.player)  # Move the item to the player
		self.visible = false  # Hide the item by setting 'visible' to false
		collected = true  # Mark the item as collected to prevent it from being collected again
