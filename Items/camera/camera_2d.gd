extends Camera2D

# Reference to the health number label
@onready var health_number = $health_number
@onready var notification_label = $Notifacations

const NOTIFICATION_TIME = 5

func notify(message: String):
	if not notification_label:
		return
	notification_label.text = message
	
	# Wait for the specified notification time before clearing the text
	await get_tree().create_timer(NOTIFICATION_TIME).timeout
	
	notification_label.text = ""
	Global.notifacation_message = "" 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Make sure you're using str() to convert notification message to a string
	if Global.notifacation_message != "":
		notify(str(Global.notifacation_message))  # Corrected here: Use str() instead of var_to_str()

	# Ensure the health_number exists and update it
	if health_number:
		health_number.text = str(Global.player_lives)  # Convert player lives to string
