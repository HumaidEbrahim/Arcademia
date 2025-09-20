extends Area2D

signal left_safe_area
signal entered_safe_area  # Add this signal to the Player script

var original_position: Vector2

# Use @onready to ensure the node is loaded before it's accessed
# This path is relative to the player node.
@onready var safe_area_node = get_node("../SafeArea")

func _ready() -> void:
	original_position = self.position
	
	# Connect the signal if the node was found
	if safe_area_node:
		safe_area_node.area_exited.connect(_on_safe_area_area_exited)
		safe_area_node.area_entered.connect(_on_safe_area_area_entered) # Connect area_entered signal
	else:
		# This print statement will help you debug if the path is wrong
		print("ERROR: SafeArea node not found!")
		

func _on_safe_area_area_exited(area: Area2D) -> void:
	if area == self:
		print("Player left the safe area! Returning to origin.")
		self.position = original_position
		emit_signal("left_safe_area")

func _on_safe_area_area_entered(area: Area2D) -> void:
	if area == self:
		print("Player entered the safe area.")
		emit_signal("entered_safe_area") # Emit the signal to the UI
